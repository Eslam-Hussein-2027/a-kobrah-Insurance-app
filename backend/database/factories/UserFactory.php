<?php

namespace Database\Factories;

use App\Enums\UserRole;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<User>
 */
class UserFactory extends Factory
{
    public function definition(): array
    {
        return [
            'name' => fake()->name(),
            'phone' => '091'.fake()->unique()->numerify('#######'),
            'national_id' => '1'.fake()->unique()->numerify('###########'),
            'password' => null,
            'role' => UserRole::Customer,
            'phone_verified_at' => now(),
            'is_active' => true,
        ];
    }

    /**
     * Keep the spatie role assignment in sync with the `role` column.
     */
    public function configure(): static
    {
        return $this->afterCreating(fn (User $user) => $user->syncRoles([$user->role->value]));
    }

    public function role(UserRole $role): static
    {
        return $this->state(['role' => $role]);
    }

    public function admin(): static
    {
        return $this->role(UserRole::Admin);
    }

    public function surveyor(): static
    {
        return $this->role(UserRole::Surveyor);
    }

    public function withKycDocuments(): static
    {
        return $this->state([
            'id_image' => 'users/demo/documents/id.jpg',
            'license_image' => 'users/demo/documents/license.jpg',
        ]);
    }

    public function inactive(): static
    {
        return $this->state(['is_active' => false]);
    }
}
