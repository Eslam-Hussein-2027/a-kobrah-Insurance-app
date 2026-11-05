<?php

namespace Tests;

use App\Enums\UserRole;
use App\Models\User;
use App\Services\Sms\SmsSender;
use Database\Seeders\CoverageTypeSeeder;
use Database\Seeders\PricingFactorSeeder;
use Database\Seeders\RolesAndPermissionsSeeder;
use Illuminate\Foundation\Testing\TestCase as BaseTestCase;
use Laravel\Sanctum\Sanctum;
use Tests\Fakes\FakeSmsSender;

abstract class TestCase extends BaseTestCase
{
    /** Used by RefreshDatabase: every DB test starts with roles & permissions. */
    protected bool $seed = true;

    protected string $seeder = RolesAndPermissionsSeeder::class;

    protected FakeSmsSender $sms;

    protected function setUp(): void
    {
        parent::setUp();

        $this->sms = new FakeSmsSender;
        $this->app->instance(SmsSender::class, $this->sms);

        // Symfony's test requests default to "Accept-Language: en-us"; the mobile app always sends its UI language.
        $this->withHeader('Accept-Language', 'ar');
    }

    protected function seedPricing(): void
    {
        $this->seed([CoverageTypeSeeder::class, PricingFactorSeeder::class]);
    }

    protected function customer(array $attributes = []): User
    {
        return User::factory()->withKycDocuments()->create($attributes);
    }

    protected function admin(): User
    {
        return User::factory()->role(UserRole::Admin)->create();
    }

    protected function actingAsUser(User $user): static
    {
        Sanctum::actingAs($user);

        return $this;
    }
}
