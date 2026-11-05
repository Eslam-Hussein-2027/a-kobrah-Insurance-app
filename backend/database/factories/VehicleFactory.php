<?php

namespace Database\Factories;

use App\Models\User;
use App\Models\Vehicle;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Vehicle>
 */
class VehicleFactory extends Factory
{
    public function definition(): array
    {
        return [
            'user_id' => User::factory(),
            'plate_no' => fake()->randomElement(['ق ط ن', 'م ص ر', 'ب س ع']).' '.fake()->unique()->numerify('####'),
            // VIN alphabet excludes I, O, Q
            'vin' => strtoupper(fake()->unique()->regexify('[A-HJ-NPR-Z0-9]{17}')),
            'make' => fake()->randomElement(['Toyota', 'Hyundai', 'Kia', 'Nissan', 'Chevrolet']),
            'model' => fake()->randomElement(['Corolla', 'Elantra', 'Cerato', 'Sunny', 'Optra']),
            'year' => fake()->numberBetween(2010, (int) now()->year),
            'engine_cc' => fake()->randomElement([1300, 1600, 2000]),
        ];
    }
}
