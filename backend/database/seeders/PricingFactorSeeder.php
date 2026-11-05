<?php

namespace Database\Seeders;

use App\Enums\PricingFactorType;
use App\Models\PricingFactor;
use Illuminate\Database\Seeder;

/**
 * Default pricing bands. Ranges are inclusive; max = null means "and above".
 * Every factor type must cover the full input range (0 → ∞) or quotes will fail with a clear error.
 */
class PricingFactorSeeder extends Seeder
{
    /**
     * @var array<string, list<array{0: int, 1: int|null, 2: float}>>
     */
    private const BANDS = [
        // Vehicle age in years
        'vehicle_age' => [
            [0, 3, 1.000],
            [4, 7, 1.100],
            [8, 12, 1.250],
            [13, 20, 1.400],
            [21, null, 1.600],
        ],
        // Engine capacity in cc
        'engine_cc' => [
            [0, 1300, 1.000],
            [1301, 1600, 1.100],
            [1601, 2000, 1.250],
            [2001, 3000, 1.450],
            [3001, null, 1.700],
        ],
        // Non-rejected claims in the look-back window
        'claims_history' => [
            [0, 0, 1.000],
            [1, 1, 1.150],
            [2, 2, 1.300],
            [3, null, 1.500],
        ],
    ];

    public function run(): void
    {
        foreach (self::BANDS as $type => $bands) {
            $factorType = PricingFactorType::from($type);

            PricingFactor::query()->ofType($factorType)->delete();

            foreach ($bands as [$min, $max, $multiplier]) {
                PricingFactor::create([
                    'factor_type' => $factorType,
                    'min_value' => $min,
                    'max_value' => $max,
                    'multiplier' => $multiplier,
                ]);
            }
        }
    }
}
