<?php

namespace Tests\Feature;

use App\Enums\PricingFactorType;
use App\Models\Claim;
use App\Models\CoverageType;
use App\Models\Policy;
use App\Models\PricingFactor;
use App\Models\User;
use App\Models\Vehicle;
use Carbon\CarbonImmutable;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Testing\TestResponse;
use PHPUnit\Framework\Attributes\DataProvider;
use Tests\TestCase;

/**
 * premium = base_price × vehicle_age_factor × engine_factor × claims_history_factor
 * Bands from the test fixture (TestCase::seedPricing), independent of the production tariff:
 *   age:    0-3 ×1.000 | 4-7 ×1.100 | 8-12 ×1.250 | 13-20 ×1.400 | 21+ ×1.600
 *   engine: 0-1300 ×1.000 | 1301-1600 ×1.100 | 1601-2000 ×1.250 | 2001-3000 ×1.450 | 3001+ ×1.700
 *   claims: 0 ×1.000 | 1 ×1.150 | 2 ×1.300 | 3+ ×1.500
 * Base prices: THIRD_PARTY 1200.00, COMPREHENSIVE 6500.00
 */
class QuoteCalculationTest extends TestCase
{
    use RefreshDatabase;

    private User $customer;

    protected function setUp(): void
    {
        parent::setUp();

        $this->travelTo(CarbonImmutable::parse('2026-06-01 10:00:00'));
        $this->seedPricing();
        $this->customer = $this->customer();
    }

    private function quote(Vehicle $vehicle, string $coverageCode): TestResponse
    {
        return $this->actingAsUser($this->customer)->postJson('/api/v1/quotes', [
            'vehicle_id' => $vehicle->id,
            'coverage_type_id' => CoverageType::query()->where('code', $coverageCode)->value('id'),
        ]);
    }

    public function test_premium_is_base_price_times_all_factors(): void
    {
        // age 6 → 1.100, 1600cc → 1.100, 0 claims → 1.000  ⇒ 6500 × 1.1 × 1.1 = 7865.00
        $vehicle = Vehicle::factory()->for($this->customer)->create(['year' => 2020, 'engine_cc' => 1600]);

        $this->quote($vehicle, CoverageType::COMPREHENSIVE)
            ->assertOk()
            ->assertJsonPath('data.base_price', '6500.00')
            ->assertJsonPath('data.premium', '7865.00')
            ->assertJsonPath('data.currency', 'LYD')
            ->assertJsonPath('data.factors.0.type', 'vehicle_age')
            ->assertJsonPath('data.factors.0.input', 6)
            ->assertJsonPath('data.factors.0.multiplier', '1.100')
            ->assertJsonPath('data.factors.1.type', 'engine_cc')
            ->assertJsonPath('data.factors.1.multiplier', '1.100')
            ->assertJsonPath('data.factors.2.type', 'claims_history')
            ->assertJsonPath('data.factors.2.input', 0)
            ->assertJsonPath('data.factors.2.multiplier', '1.000');
    }

    /**
     * Range bounds are inclusive; NULL max is open-ended.
     */
    #[DataProvider('bandBoundaries')]
    public function test_band_boundaries(int $year, int $engineCc, string $expectedPremium): void
    {
        $vehicle = Vehicle::factory()->for($this->customer)->create(['year' => $year, 'engine_cc' => $engineCc]);

        $this->quote($vehicle, CoverageType::THIRD_PARTY)
            ->assertOk()
            ->assertJsonPath('data.premium', $expectedPremium);
    }

    public static function bandBoundaries(): array
    {
        return [
            'age 3 (upper bound), 1300cc (upper bound)' => [2023, 1300, '1200.00'],   // 1200 × 1.0 × 1.0
            'age 4 (lower bound), 1301cc (lower bound)' => [2022, 1301, '1452.00'],   // 1200 × 1.1 × 1.1
            'age 25 (open-ended), 3500cc (open-ended)' => [2001, 3500, '3264.00'],    // 1200 × 1.6 × 1.7
            'brand-new car (age 0)' => [2026, 2000, '1500.00'],                        // 1200 × 1.0 × 1.25
            'next model year (age clamps to 0)' => [2027, 1600, '1320.00'],            // 1200 × 1.0 × 1.1
        ];
    }

    public function test_claims_history_counts_owner_claims_across_vehicles_within_window(): void
    {
        $vehicle = Vehicle::factory()->for($this->customer)->create(['year' => 2026, 'engine_cc' => 1300]);
        $otherVehicle = Vehicle::factory()->for($this->customer)->create();

        $policy = Policy::factory()->active()->for($vehicle)->create();
        $otherPolicy = Policy::factory()->active()->for($otherVehicle)->create();

        Claim::factory()->for($policy)->create(['incident_date' => now()->subMonths(3)]);       // counted
        Claim::factory()->for($otherPolicy)->create(['incident_date' => now()->subYears(2)]);   // counted (other car, same owner)
        Claim::factory()->for($policy)->rejected()->create();                                   // ignored: rejected
        Claim::factory()->for($policy)->create(['incident_date' => now()->subYears(4)]);        // ignored: outside 3-year window
        Claim::factory()->create();                                                             // ignored: another customer

        // 2 claims → 1.300 ⇒ 1200 × 1.0 × 1.0 × 1.3 = 1560.00
        $this->quote($vehicle, CoverageType::THIRD_PARTY)
            ->assertOk()
            ->assertJsonPath('data.factors.2.input', 2)
            ->assertJsonPath('data.factors.2.multiplier', '1.300')
            ->assertJsonPath('data.premium', '1560.00');
    }

    public function test_factors_are_read_from_the_database_not_hardcoded(): void
    {
        $vehicle = Vehicle::factory()->for($this->customer)->create(['year' => 2020, 'engine_cc' => 1600]);

        PricingFactor::query()
            ->ofType(PricingFactorType::VehicleAge)
            ->where('min_value', 4)
            ->update(['multiplier' => 2.000]);

        // 6500 × 2.0 × 1.1 = 14300.00
        $this->quote($vehicle, CoverageType::COMPREHENSIVE)->assertJsonPath('data.premium', '14300.00');

        $coverage = CoverageType::query()->where('code', CoverageType::COMPREHENSIVE)->firstOrFail();
        $coverage->update(['base_price' => 5000]);

        // 5000 × 2.0 × 1.1 = 11000.00
        $this->quote($vehicle, CoverageType::COMPREHENSIVE)->assertJsonPath('data.premium', '11000.00');
    }

    public function test_missing_factor_band_is_a_clear_error_not_a_silent_default(): void
    {
        $vehicle = Vehicle::factory()->for($this->customer)->create(['engine_cc' => 5000]);
        PricingFactor::query()->ofType(PricingFactorType::EngineCc)->whereNull('max_value')->delete();

        $this->quote($vehicle, CoverageType::THIRD_PARTY)
            ->assertUnprocessable()
            ->assertJsonPath('message', 'لا يوجد معامل تسعير مُعرّف لـ (سعة المحرك) بالقيمة 5000. يرجى التواصل مع خدمة العملاء.');
    }

    public function test_inactive_coverage_type_cannot_be_quoted(): void
    {
        $vehicle = Vehicle::factory()->for($this->customer)->create();
        CoverageType::query()->where('code', CoverageType::COMPREHENSIVE)->update(['is_active' => false]);

        $this->quote($vehicle, CoverageType::COMPREHENSIVE)
            ->assertUnprocessable()
            ->assertJsonPath('message', 'نوع التغطية المختار غير متاح حالياً.');
    }

    public function test_customer_cannot_quote_someone_elses_vehicle(): void
    {
        $vehicle = Vehicle::factory()->create();

        $this->quote($vehicle, CoverageType::THIRD_PARTY)->assertForbidden();
    }

    public function test_coverage_types_endpoint_lists_active_types_localized(): void
    {
        CoverageType::factory()->inactive()->create();

        $this->getJson('/api/v1/coverage-types')
            ->assertOk()
            ->assertJsonCount(2, 'data')
            ->assertJsonPath('data.0.code', CoverageType::THIRD_PARTY)
            ->assertJsonPath('data.0.name', 'التأمين الإجباري (ضد الغير)');

        $this->getJson('/api/v1/coverage-types', ['Accept-Language' => 'en'])
            ->assertJsonPath('data.0.name', 'Compulsory Third-Party Insurance');
    }
}
