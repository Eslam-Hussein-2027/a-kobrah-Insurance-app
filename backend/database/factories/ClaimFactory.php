<?php

namespace Database\Factories;

use App\Enums\ClaimStatus;
use App\Models\Claim;
use App\Models\Policy;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Claim>
 */
class ClaimFactory extends Factory
{
    public function definition(): array
    {
        return [
            'claim_no' => sprintf('CLM-%d-%06d', now()->year, fake()->unique()->numberBetween(1, 999999)),
            'policy_id' => Policy::factory()->active(),
            'incident_date' => now()->subMonths(2),
            'lat' => 30.0444196,
            'lng' => 31.2357116,
            'description' => 'تصادم بسيط في الصدام الأمامي.',
            'status' => ClaimStatus::Submitted,
        ];
    }

    public function rejected(): static
    {
        return $this->state(['status' => ClaimStatus::Rejected, 'rejection_reason' => 'بيانات غير مكتملة']);
    }
}
