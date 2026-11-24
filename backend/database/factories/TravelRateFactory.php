<?php

namespace Database\Factories;

use App\Enums\TravelZone;
use App\Models\TravelRate;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<TravelRate>
 */
class TravelRateFactory extends Factory
{
    public function definition(): array
    {
        return [
            'zone' => TravelZone::Schengen,
            'days' => 15,
            'price' => 85.00,
            'is_active' => true,
        ];
    }
}
