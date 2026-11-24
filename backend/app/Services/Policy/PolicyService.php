<?php

namespace App\Services\Policy;

use App\Enums\InsuranceProduct;
use App\Enums\PaymentMethod;
use App\Enums\PaymentStatus;
use App\Enums\PolicyStatus;
use App\Enums\TravelZone;
use App\Exceptions\BusinessRuleException;
use App\Jobs\GeneratePolicyPdf;
use App\Models\CoverageType;
use App\Models\InsuredPerson;
use App\Models\Policy;
use App\Models\User;
use App\Models\Vehicle;
use App\Services\DocumentNumberGenerator;
use App\Services\Pricing\QuoteService;
use App\Services\Pricing\TravelQuoteService;
use Carbon\CarbonImmutable;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\DB;

class PolicyService
{
    public function __construct(
        private readonly QuoteService $quotes,
        private readonly TravelQuoteService $travelQuotes,
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
        $end = $this->motorEndDate($start);

        if ($this->hasOverlappingPolicy($vehicle, $start, $end)) {
            throw new BusinessRuleException(__('messages.policy.overlap'));
        }

        $quote = $this->quotes->calculate($vehicle, $coverageType);

        return DB::transaction(fn () => Policy::create([
            'policy_no' => $this->numbers->next((string) config('insurance.policy.number_prefix')),
            'user_id' => $customer->id,
            'product' => InsuranceProduct::Motor,
            'vehicle_id' => $vehicle->id,
            'coverage_type_id' => $coverageType->id,
            'start_date' => $start,
            'end_date' => $end,
            'premium' => $quote->premium,
            'pricing_snapshot' => $quote->snapshot(),
            'status' => PolicyStatus::PendingPayment,
        ]));
    }

    /**
     * Travel policy awaiting payment, for one or more of the customer's saved persons.
     *
     * @param  Collection<int, InsuredPerson>  $travellers
     */
    public function createPendingTravel(
        User $customer,
        TravelZone $zone,
        int $days,
        CarbonImmutable $startDate,
        Collection $travellers,
    ): Policy {
        $withoutPassport = $travellers->filter(fn (InsuredPerson $person) => blank($person->passport_no));

        if ($withoutPassport->isNotEmpty()) {
            throw new BusinessRuleException(__('messages.travel.passport_required', [
                'names' => $withoutPassport->pluck('full_name')->implode('، '),
            ]));
        }

        $quote = $this->travelQuotes->quote($zone, $days, $travellers->count());
        $start = $startDate->startOfDay();

        return DB::transaction(function () use ($customer, $zone, $days, $start, $travellers, $quote) {
            $policy = Policy::create([
                'policy_no' => $this->numbers->next((string) config('insurance.policy.number_prefix')),
                'user_id' => $customer->id,
                'product' => InsuranceProduct::Travel,
                'travel_zone' => $zone,
                'travel_days' => $days,
                'start_date' => $start,
                'end_date' => $start->addDays($days - 1),
                'premium' => $quote->premium,
                'pricing_snapshot' => $quote->snapshot(),
                'status' => PolicyStatus::PendingPayment,
            ]);

            $policy->travellers()->createMany($travellers->map(fn (InsuredPerson $person) => [
                'insured_person_id' => $person->id,
                'full_name' => $person->full_name,
                'birth_date' => $person->birth_date,
                'passport_no' => $person->passport_no,
            ])->all());

            return $policy;
        });
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
            $attributes['end_date'] = $this->endDateFor($policy, $today);
        }

        $policy->update($attributes);

        GeneratePolicyPdf::dispatch($policy->id)->afterCommit();

        return $policy;
    }

    /** Same term length as purchased: one year (motor) or the trip length (travel). */
    private function endDateFor(Policy $policy, CarbonImmutable $start): CarbonImmutable
    {
        return $policy->isTravel()
            ? $start->addDays((int) $policy->travel_days - 1)
            : $this->motorEndDate($start);
    }

    private function motorEndDate(CarbonImmutable $start): CarbonImmutable
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
