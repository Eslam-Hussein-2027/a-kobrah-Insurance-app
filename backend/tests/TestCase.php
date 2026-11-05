<?php

namespace Tests;

use App\Enums\PricingFactorType;
use App\Enums\UserRole;
use App\Models\CoverageType;
use App\Models\PricingFactor;
use App\Models\User;
use App\Services\Sms\SmsSender;
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

    /**
     * Fixed pricing fixture, independent of the production seeders (whose prices change with the
     * company's tariff). Bands:
     *   age:    0-3 ×1.000 | 4-7 ×1.100 | 8-12 ×1.250 | 13-20 ×1.400 | 21+ ×1.600
     *   engine: 0-1300 ×1.000 | 1301-1600 ×1.100 | 1601-2000 ×1.250 | 2001-3000 ×1.450 | 3001+ ×1.700
     *   claims: 0 ×1.000 | 1 ×1.150 | 2 ×1.300 | 3+ ×1.500
     * Base prices: THIRD_PARTY 1200.00, COMPREHENSIVE 6500.00 (both active).
     */
    protected function seedPricing(): void
    {
        CoverageType::factory()->create([
            'code' => CoverageType::THIRD_PARTY,
            'name' => 'التأمين الإجباري (ضد الغير)',
            'name_en' => 'Compulsory Third-Party Insurance',
            'base_price' => 1200.00,
            'is_mandatory' => true,
        ]);

        CoverageType::factory()->create([
            'code' => CoverageType::COMPREHENSIVE,
            'name' => 'التأمين الشامل',
            'name_en' => 'Comprehensive',
            'base_price' => 6500.00,
        ]);

        $bands = [
            'vehicle_age' => [[0, 3, 1.000], [4, 7, 1.100], [8, 12, 1.250], [13, 20, 1.400], [21, null, 1.600]],
            'engine_cc' => [[0, 1300, 1.000], [1301, 1600, 1.100], [1601, 2000, 1.250], [2001, 3000, 1.450], [3001, null, 1.700]],
            'claims_history' => [[0, 0, 1.000], [1, 1, 1.150], [2, 2, 1.300], [3, null, 1.500]],
        ];

        foreach ($bands as $type => $rows) {
            foreach ($rows as [$min, $max, $multiplier]) {
                PricingFactor::factory()->create([
                    'factor_type' => PricingFactorType::from($type),
                    'min_value' => $min,
                    'max_value' => $max,
                    'multiplier' => $multiplier,
                ]);
            }
        }
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
