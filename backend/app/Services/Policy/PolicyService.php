<?php

namespace App\Services\Policy;

use App\Enums\PaymentMethod;
use App\Enums\PaymentStatus;
use App\Enums\PolicyStatus;
use App\Exceptions\BusinessRuleException;
use App\Jobs\GeneratePolicyPdf;
use App\Models\CoverageType;
use App\Models\Policy;
use App\Models\User;
use App\Models\Vehicle;
use App\Services\DocumentNumberGenerator;
use App\Services\Pricing\QuoteService;
use Carbon\CarbonImmutable;
use Illuminate\Support\Facades\DB;

class PolicyService
{
    public function __construct(
        private readonly QuoteService $quotes,
        private readonly DocumentNumberGenerator $numbers,
    ) {}

    /**
     * Create a policy awaiting payment. The premium is always recalculated server-side.
     */
    public function createPending(
        User $customer,
        Vehicle $vehicle,
        CoverageType $coverageType,
        ?CarbonImmutable $startDate = null,
    ): Policy {
        if (! $customer->hasKycDocuments()) {
            throw new BusinessRuleException(__('messages.policy.kyc_required'));
        }

        $start = ($startDate ?? CarbonImmutable::today())->startOfDay();
        $end = $this->endDateFor($start);

        if ($this->hasOverlappingPolicy($vehicle, $start, $end)) {
            throw new BusinessRuleException(__('messages.policy.overlap'));
        }

        $quote = $this->quotes->calculate($vehicle, $coverageType);

        return DB::transaction(fn () => Policy::create([
            'policy_no' => $this->numbers->next((string) config('insurance.policy.number_prefix')),
            'vehicle_id' => $vehicle->id,
            'coverage_type_id' => $coverageType->id,
            'start_date' => $start,
            'end_date' => $end,
            'premium' => $quote->premium,
            'pricing_snapshot' => $quote->snapshot(),
            'status' => PolicyStatus::PendingPayment,
        ]));
    }

    public function cancelPending(Policy $policy): Policy
    {
        if (! $policy->isPendingPayment()) {
            throw new BusinessRuleException(__('messages.policy.not_pending'));
        }

        $policy->update(['status' => PolicyStatus::Cancelled]);

        return $policy;
    }

    /**
     * "Pay at office": an admin records the cash/POS payment and the policy is activated.
     * Online payments activate through PaymentService::sync() → activate().
     */
    public function confirmOfficePayment(Policy $policy, User $admin, ?string $receiptReference = null): Policy
    {
        return DB::transaction(function () use ($policy, $admin, $receiptReference) {
            /** @var Policy $locked */
            $locked = Policy::query()->whereKey($policy->id)->lockForUpdate()->firstOrFail();

            if (! $locked->isPendingPayment()) {
                throw new BusinessRuleException(__('messages.policy.not_pending'));
            }

            $locked->payments()
                ->where('method', PaymentMethod::Online)
                ->where('status', PaymentStatus::Pending)
                ->update(['status' => PaymentStatus::Failed, 'failure_reason' => 'paid_at_office']);

            $locked->payments()->create([
                'amount' => $locked->premium,
                'method' => PaymentMethod::Office,
                'gateway_ref' => $receiptReference,
                'status' => PaymentStatus::Paid,
                'paid_at' => now(),
                'confirmed_by' => $admin->id,
            ]);

            return $this->activate($locked);
        });
    }

    /**
     * Move a paid policy to ACTIVE and queue its PDF.
     * If payment arrived after the requested start date, coverage starts today (full term preserved).
     */
    public function activate(Policy $policy): Policy
    {
        $today = CarbonImmutable::today();
        $attributes = [
            'status' => PolicyStatus::Active,
            'issued_at' => now(),
        ];

        if ($policy->start_date->lt($today)) {
            $attributes['start_date'] = $today;
            $attributes['end_date'] = $this->endDateFor($today);
        }

        $policy->update($attributes);

        GeneratePolicyPdf::dispatch($policy->id)->afterCommit();

        return $policy;
    }

    private function endDateFor(CarbonImmutable $start): CarbonImmutable
    {
        return $start->addMonthsNoOverflow((int) config('insurance.policy.duration_months'))->subDay();
    }

    private function hasOverlappingPolicy(Vehicle $vehicle, CarbonImmutable $start, CarbonImmutable $end): bool
    {
        return $vehicle->policies()
            ->whereIn('status', PolicyStatus::blocking())
            ->whereDate('start_date', '<=', $end)
            ->whereDate('end_date', '>=', $start)
            ->exists();
    }
}
