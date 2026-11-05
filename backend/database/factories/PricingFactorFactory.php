<?php

namespace Database\Factories;

use App\Enums\PricingFactorType;
use App\Models\PricingFactor;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<PricingFactor>
 */
class PricingFactorFactory extends Factory
{
    public function definition(): array
    {
        return [
            'factor_type' => PricingFactorType::VehicleAge,
            'min_value' => 0,
            'max_value' => null,
            'multiplier' => 1.000,
        ];
    }
}
