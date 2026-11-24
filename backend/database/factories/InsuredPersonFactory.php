<?php

namespace Database\Factories;

use App\Enums\PersonRelationship;
use App\Models\InsuredPerson;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<InsuredPerson>
 */
class InsuredPersonFactory extends Factory
{
    public function definition(): array
    {
        return [
            'user_id' => User::factory(),
            'full_name' => fake('ar_SA')->name(),
            'relationship' => PersonRelationship::Self,
            'birth_date' => fake()->dateTimeBetween('-60 years', '-18 years')->format('Y-m-d'),
            'passport_no' => strtoupper(fake()->unique()->bothify('??######')),
            'national_id' => null,
        ];
    }
}
