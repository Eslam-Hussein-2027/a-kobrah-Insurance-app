<?php

namespace Database\Factories;

use App\Enums\LicensePurpose;
use App\Enums\LicensingAuthority;
use App\Enums\ManufactureCountry;
use App\Enums\VehicleColor;
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
            'owner_name' => fake()->name(),
            'owner_address' => 'بنغازي - '.fake()->streetName(),
            // Libyan format: region code - number
            'plate_no' => fake()->numberBetween(1, 70).'-'.fake()->unique()->numerify('######'),
            // VIN alphabet excludes I, O, Q
            'vin' => strtoupper(fake()->unique()->regexify('[A-HJ-NPR-Z0-9]{17}')),
            'make' => fake()->randomElement(['Toyota', 'Hyundai', 'Kia', 'Nissan', 'Chevrolet']),
            'model' => fake()->randomElement(['Corolla', 'Elantra', 'Cerato', 'Sunny', 'Optra']),
            'year' => fake()->numberBetween(2010, (int) now()->year),
            'engine_cc' => fake()->randomElement([1300, 1600, 2000]),
            'color' => fake()->randomElement(VehicleColor::cases()),
            'country_of_origin' => fake()->randomElement([ManufactureCountry::Japan, ManufactureCountry::SouthKorea]),
            'license_purpose' => LicensePurpose::Private,
            'seats' => 5,
            'licensing_authority' => fake()->randomElement([LicensingAuthority::Benghazi, LicensingAuthority::Tripoli]),
        ];
    }
}
