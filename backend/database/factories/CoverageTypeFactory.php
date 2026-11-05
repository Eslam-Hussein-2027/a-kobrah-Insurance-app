<?php

namespace Database\Factories;

use App\Models\CoverageType;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<CoverageType>
 */
class CoverageTypeFactory extends Factory
{
    public function definition(): array
    {
        return [
            'code' => strtoupper(fake()->unique()->lexify('COV_????')),
            'name' => 'تغطية تجريبية',
            'name_en' => 'Test coverage',
            'base_price' => 1000.00,
            'is_mandatory' => false,
            'is_active' => true,
        ];
    }

    public function inactive(): static
    {
        return $this->state(['is_active' => false]);
    }
}
