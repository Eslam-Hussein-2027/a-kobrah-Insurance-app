<?php

namespace App\Services\Payments;

use App\Models\Payment;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\URL;
use Illuminate\Support\Str;

/**
 * Fake provider for development and demos. Its "payment page" is a signed page in this app
 * (/payments/simulator/{payment}) with "pay" / "decline" buttons; the outcome is kept in the cache,
 * which plays the role of the provider's own database.
 */
class SimulatorGateway implements PaymentGateway
{
    private const CACHE_PREFIX = 'payment-simulator:';

    public function name(): string
    {
        return 'simulator';
    }

    public function createCheckout(Payment $payment): CheckoutSession
    {
        $reference = 'SIM-'.Str::upper(Str::random(12));

        $url = URL::temporarySignedRoute(
            'payments.simulator.show',
            now()->addMinutes((int) config('payments.checkout_ttl_minutes')),
            ['payment' => $payment->id, 'reference' => $reference],
        );

        return new CheckoutSession($reference, $url);
    }

    public function fetchStatus(Payment $payment): GatewayResult
    {
        $state = Cache::get(self::CACHE_PREFIX.$payment->gateway_ref);

        return match ($state['status'] ?? null) {
            'paid' => GatewayResult::paid($state['amount'], $state),
            'failed' => GatewayResult::failed('declined', $state),
            default => GatewayResult::pending(),
        };
    }

    public function referenceFromCallback(Request $request): ?string
    {
        return $request->input('reference');
    }

    /** Called by the simulator page (stands in for the customer acting on the provider's page). */
    public function record(Payment $payment, bool $success): void
    {
        Cache::put(self::CACHE_PREFIX.$payment->gateway_ref, [
            'status' => $success ? 'paid' : 'failed',
            'amount' => (string) $payment->amount,
            'at' => now()->toIso8601String(),
        ], now()->addDay());
    }
}
