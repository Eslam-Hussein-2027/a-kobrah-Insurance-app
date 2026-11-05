<?php

namespace App\Services\Pricing;

use App\Enums\PricingFactorType;
use App\Models\CoverageType;
use App\Models\Vehicle;
use Carbon\CarbonImmutable;

/**
 * Immutable result of a premium calculation.
 */
final readonly class Quote
{
    /**
     * @param  list<array{type: PricingFactorType, input: int, multiplier: string, factor_id: int}>  $factors
     */
    public function __construct(
        public Vehicle $vehicle,
        public CoverageType $coverageType,
        public string $basePrice,
        public array $factors,
        public string $premium,
        public string $currency,
        public CarbonImmutable $calculatedAt,
    ) {}

    /**
     * Persisted on the policy for audit (pricing factors are admin-editable).
     *
     * @return array<string, mixed>
     */
    public function snapshot(): array
    {
        return [
            'coverage_type_code' => $this->coverageType->code,
            'base_price' => $this->basePrice,
            'factors' => array_map(fn (array $factor) => [
                'type' => $factor['type']->value,
                'input' => $factor['input'],
                'multiplier' => $factor['multiplier'],
                'factor_id' => $factor['factor_id'],
            ], $this->factors),
            'premium' => $this->premium,
            'currency' => $this->currency,
            'calculated_at' => $this->calculatedAt->toIso8601String(),
        ];
    }
}
