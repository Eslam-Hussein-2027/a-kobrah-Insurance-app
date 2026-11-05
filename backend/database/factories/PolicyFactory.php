<?php

namespace Database\Factories;

use App\Enums\PolicyStatus;
use App\Models\CoverageType;
use App\Models\Policy;
use App\Models\Vehicle;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Policy>
 */
class PolicyFactory extends Factory
{
    public function definition(): array
    {
        $start = now()->startOfDay();

        return [
            'policy_no' => sprintf('POL-%d-%06d', $start->year, fake()->unique()->numberBetween(1, 999999)),
            'vehicle_id' => Vehicle::factory(),
            'coverage_type_id' => CoverageType::factory(),
            'start_date' => $start,
            'end_date' => $start->addYear()->subDay(),
            'premium' => 1500.00,
            'status' => PolicyStatus::PendingPayment,
        ];
    }

    public function active(): static
    {
        return $this->state(['status' => PolicyStatus::Active, 'issued_at' => now()]);
    }

    public function expired(): static
    {
        return $this->state([
            'status' => PolicyStatus::Expired,
            'start_date' => now()->subYears(2)->startOfDay(),
            'end_date' => now()->subYear()->subDay()->startOfDay(),
            'issued_at' => now()->subYears(2),
        ]);
    }

    public function cancelled(): static
    {
        return $this->state(['status' => PolicyStatus::Cancelled]);
    }
}
