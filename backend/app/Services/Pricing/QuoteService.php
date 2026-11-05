<?php

namespace App\Services\Pricing;

use App\Enums\ClaimStatus;
use App\Enums\PricingFactorType;
use App\Exceptions\BusinessRuleException;
use App\Models\Claim;
use App\Models\CoverageType;
use App\Models\PricingFactor;
use App\Models\Vehicle;
use Carbon\CarbonImmutable;
use Illuminate\Support\Collection;

/**
 * premium = base_price × vehicle_age_factor × engine_factor × claims_history_factor
 *
 * All multipliers come from the pricing_factors table (admin-configurable).
 * A missing range is treated as a configuration error — we never silently default to 1.0.
 */
class QuoteService
{
    public function calculate(Vehicle $vehicle, CoverageType $coverageType): Quote
    {
        if (! $coverageType->is_active) {
            throw new BusinessRuleException(__('messages.quote.coverage_inactive'));
        }

        $inputs = $this->factorInputs($vehicle);
        $rules = PricingFactor::query()->orderByDesc('min_value')->get()
            ->groupBy(fn (PricingFactor $factor) => $factor->factor_type->value);

        $premium = (float) $coverageType->base_price;
        $applied = [];

        foreach ($inputs as $typeValue => $input) {
            $type = PricingFactorType::from($typeValue);
            $factor = $this->matchFactor($rules->get($typeValue, collect()), $type, $input);

            $premium *= (float) $factor->multiplier;
            $applied[] = [
                'type' => $type,
                'input' => $input,
                'multiplier' => (string) $factor->multiplier,
                'factor_id' => $factor->id,
            ];
        }

        return new Quote(
            vehicle: $vehicle,
            coverageType: $coverageType,
            basePrice: (string) $coverageType->base_price,
            factors: $applied,
            premium: number_format(round($premium, 2, PHP_ROUND_HALF_UP), 2, '.', ''),
            currency: (string) config('insurance.currency'),
            calculatedAt: CarbonImmutable::now(),
        );
    }

    /**
     * @return array<string, int> keyed by PricingFactorType value
     */
    private function factorInputs(Vehicle $vehicle): array
    {
        return [
            PricingFactorType::VehicleAge->value => $vehicle->ageInYears(),
            PricingFactorType::EngineCc->value => $vehicle->engine_cc,
            PricingFactorType::ClaimsHistory->value => $this->ownerClaimsCount($vehicle),
        ];
    }

    /**
     * Claims history follows the policyholder (all of the owner's vehicles), not a single car.
     */
    private function ownerClaimsCount(Vehicle $vehicle): int
    {
        $years = (int) config('insurance.quote.claims_history_years');

        return Claim::query()
            ->whereHas('policy.vehicle', fn ($query) => $query->where('user_id', $vehicle->user_id))
            ->where('status', '!=', ClaimStatus::Rejected)
            ->where('incident_date', '>=', now()->subYears($years))
            ->count();
    }

    /**
     * @param  Collection<int, PricingFactor>  $candidates  ordered by min_value desc (most specific first)
     */
    private function matchFactor(Collection $candidates, PricingFactorType $type, int $input): PricingFactor
    {
        $factor = $candidates->first(fn (PricingFactor $factor) => $factor->matches($input));

        if ($factor === null) {
            throw new BusinessRuleException(__('messages.quote.missing_factor', [
                'factor' => $type->label(),
                'value' => $input,
            ]));
        }

        return $factor;
    }
}
