<?php

namespace Database\Factories;

use App\Enums\InsuranceProduct;
use App\Enums\PolicyStatus;
use App\Enums\TravelZone;
use App\Models\CoverageType;
use App\Models\Policy;
use App\Models\User;
use App\Models\Vehicle;
use Carbon\CarbonImmutable;
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
            'product' => InsuranceProduct::Motor,
            'vehicle_id' => Vehicle::factory(),
            // The policyholder is the vehicle owner (travel policies: a new customer unless given with for()).
            'user_id' => fn (array $attributes) => $attributes['vehicle_id'] !== null
                ? Vehicle::query()->whereKey($attributes['vehicle_id'])->value('user_id')
                : User::factory(),
            'coverage_type_id' => CoverageType::factory(),
            'start_date' => $start,
            'end_date' => $start->addYear()->subDay(),
            'premium' => 1500.00,
            'status' => PolicyStatus::PendingPayment,
        ];
    }

    /** A travel policy (no vehicle). */
    public function travel(TravelZone $zone = TravelZone::Schengen, int $days = 15): static
    {
        return $this->state(fn (array $attributes) => [
            'product' => InsuranceProduct::Travel,
            'vehicle_id' => null,
            'coverage_type_id' => null,
            'travel_zone' => $zone,
            'travel_days' => $days,
            'start_date' => $attributes['start_date'],
            'end_date' => CarbonImmutable::parse($attributes['start_date'])->addDays($days - 1),
            'premium' => 85.00,
        ]);
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
