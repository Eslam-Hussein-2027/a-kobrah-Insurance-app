<?php

namespace App\Services\Payments;

use App\Enums\PaymentMethod;
use App\Enums\PaymentStatus;
use App\Exceptions\BusinessRuleException;
use App\Models\Payment;
use App\Models\Policy;
use App\Services\Policy\PolicyService;
use Illuminate\Support\Facades\DB;

class PaymentService
{
    /**
     * Attempts *we* closed (a newer attempt was started, or the customer paid at the office).
     * The customer may still complete them on the provider's page, so they stay "syncable":
     * if money arrives anyway it is recorded and flagged for refund instead of being lost.
     */
    private const CLOSED_BY_US = ['superseded', 'paid_at_office'];

    public function __construct(
        private readonly PaymentGatewayManager $gateways,
        private readonly PolicyService $policies,
    ) {}

    /**
     * Start an online payment for a policy awaiting payment and return the payment with its checkout URL.
     * Any earlier unfinished online attempt for the same policy is closed first.
     */
    public function startOnline(Policy $policy): Payment
    {
        if (! $policy->isPendingPayment()) {
            throw new BusinessRuleException(__('messages.policy.not_pending'));
        }

        $gateway = $this->gateways->default();

        $payment = DB::transaction(function () use ($policy, $gateway) {
            $policy->payments()
                ->where('method', PaymentMethod::Online)
                ->where('status', PaymentStatus::Pending)
                ->update(['status' => PaymentStatus::Failed, 'failure_reason' => 'superseded']);

            return $policy->payments()->create([
                'amount' => $policy->premium,
                'method' => PaymentMethod::Online,
                'gateway' => $gateway->name(),
                'status' => PaymentStatus::Pending,
            ]);
        });

        $session = $gateway->createCheckout($payment);
        $payment->update(['gateway_ref' => $session->reference, 'checkout_url' => $session->redirectUrl]);

        return $payment;
    }

    /**
     * Ask the provider for the authoritative status and apply it. Safe to call many times
     * (webhook retries, the app polling, the customer returning from the payment page).
     */
    public function sync(Payment $payment): Payment
    {
        if ($payment->gateway === null || ! $this->isOpenAtGateway($payment)) {
            return $payment;
        }

        $result = $this->gateways->get($payment->gateway)->fetchStatus($payment);

        return $this->apply($payment, $result);
    }

    /**
     * Webhook entry point: the gateway tells us "something changed for reference X".
     */
    public function handleCallback(string $gatewayName, ?string $reference): ?Payment
    {
        if ($reference === null) {
            return null;
        }

        $payment = Payment::query()->where('gateway', $gatewayName)->where('gateway_ref', $reference)->first();

        return $payment === null ? null : $this->sync($payment);
    }

    private function isOpenAtGateway(Payment $payment): bool
    {
        return $payment->status === PaymentStatus::Pending
            || ($payment->status === PaymentStatus::Failed && in_array($payment->failure_reason, self::CLOSED_BY_US, true));
    }

    /** Money comparison on 2-decimal strings (no float equality, bcmath not required). */
    private static function sameAmount(string $a, string $b): bool
    {
        return number_format((float) $a, 2, '.', '') === number_format((float) $b, 2, '.', '');
    }

    private function apply(Payment $payment, GatewayResult $result): Payment
    {
        if ($result->status === GatewayResult::PENDING) {
            return $payment;
        }

        return DB::transaction(function () use ($payment, $result) {
            /** @var Payment $locked */
            $locked = Payment::query()->whereKey($payment->id)->lockForUpdate()->firstOrFail();

            // Already finalized by a concurrent webhook/poll: nothing to do.
            if (! $this->isOpenAtGateway($locked)) {
                return $locked;
            }

            if ($result->status === GatewayResult::FAILED) {
                if ($locked->status !== PaymentStatus::Pending) {
                    return $locked; // already closed by us; keep our reason
                }

                $locked->update([
                    'status' => PaymentStatus::Failed,
                    'failure_reason' => $result->reason,
                    'gateway_payload' => $result->payload,
                ]);

                return $locked;
            }

            // Paid: never trust an amount we did not ask for.
            if (! self::sameAmount((string) $result->amount, (string) $locked->amount)) {
                $locked->update([
                    'status' => PaymentStatus::Failed,
                    'failure_reason' => 'amount_mismatch',
                    'requires_refund' => true,
                    'gateway_payload' => $result->payload,
                ]);

                return $locked;
            }

            $policy = Policy::query()->whereKey($locked->policy_id)->lockForUpdate()->firstOrFail();

            $locked->update([
                'status' => PaymentStatus::Paid,
                'paid_at' => now(),
                'gateway_payload' => $result->payload,
                // Policy was cancelled or already paid at the office meanwhile: money must go back.
                'requires_refund' => ! $policy->isPendingPayment(),
            ]);

            if ($policy->isPendingPayment()) {
                $this->policies->activate($policy);
            }

            return $locked;
        });
    }
}
