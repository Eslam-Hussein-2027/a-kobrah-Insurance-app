<?php

namespace Database\Seeders;

use App\Enums\TravelZone;
use App\Models\TravelRate;
use Illuminate\Database\Seeder;

/**
 * Travel tariff: price per traveller (LYD) by zone and trip length.
 * PLACEHOLDER prices — replace with the company's approved tariff (editable from the dashboard).
 */
class TravelRateSeeder extends Seeder
{
    /**
     * @var array<string, array<int, float>> zone => [days => price]
     */
    private const RATES = [
        'arab' => [7 => 35.00, 15 => 50.00, 30 => 70.00, 90 => 140.00],
        'schengen' => [7 => 60.00, 15 => 85.00, 30 => 120.00, 90 => 240.00],
        'worldwide' => [7 => 90.00, 15 => 130.00, 30 => 180.00, 90 => 360.00],
    ];

    public function run(): void
    {
        foreach (self::RATES as $zone => $rates) {
            foreach ($rates as $days => $price) {
                // Idempotent: never overwrite prices an admin has already changed.
                TravelRate::query()->firstOrCreate(
                    ['zone' => TravelZone::from($zone), 'days' => $days],
                    ['price' => $price, 'is_active' => true],
                );
            }
        }
    }
}
