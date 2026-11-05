<?php

namespace Tests\Feature\Admin;

use App\Enums\PricingFactorType;
use App\Models\CoverageType;
use App\Models\PricingFactor;
use App\Models\Vehicle;
use Carbon\CarbonImmutable;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AdminPricingTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        $this->travelTo(CarbonImmutable::parse('2026-06-01'));
        $this->seedPricing();
        $this->actingAsUser($this->admin());
    }

    public function test_pricing_overview_has_types_factors_and_no_gaps(): void
    {
        $this->getJson('/api/v1/admin/pricing')
            ->assertOk()
            ->assertJsonCount(2, 'data.coverage_types')
            ->assertJsonCount(14, 'data.factors')
            ->assertJsonCount(3, 'data.factor_types')
            ->assertJsonPath('data.gaps.vehicle_age', [])
            ->assertJsonPath('data.gaps.engine_cc', [])
            ->assertJsonPath('data.gaps.claims_history', []);
    }

    public function test_changing_the_base_price_changes_new_quotes(): void
    {
        $coverage = CoverageType::query()->where('code', CoverageType::THIRD_PARTY)->firstOrFail();

        $this->patchJson("/api/v1/admin/coverage-types/{$coverage->id}", ['base_price' => 150])
            ->assertOk()
            ->assertJsonPath('data.base_price', '150.00');

        $customer = $this->customer();
        $vehicle = Vehicle::factory()->for($customer)->create(['year' => 2024, 'engine_cc' => 1200]);

        $this->actingAsUser($customer)
            ->postJson('/api/v1/quotes', ['vehicle_id' => $vehicle->id, 'coverage_type_id' => $coverage->id])
            ->assertJsonPath('data.premium', '150.00');
    }

    public function test_overlapping_bands_are_rejected(): void
    {
        $this->postJson('/api/v1/admin/pricing-factors', [
            'factor_type' => 'engine_cc',
            'min_value' => 1500,
            'max_value' => 1800,
            'multiplier' => 1.2,
        ])
            ->assertUnprocessable()
            ->assertJsonPath('message', 'هذه الشريحة تتداخل مع شريحة موجودة (1301 - 1600).');
    }

    public function test_deleting_a_band_reports_the_gap_and_adding_it_back_fixes_it(): void
    {
        $band = PricingFactor::query()->ofType(PricingFactorType::EngineCc)->where('min_value', 1301)->firstOrFail();

        $this->deleteJson("/api/v1/admin/pricing-factors/{$band->id}")->assertOk();
        $this->getJson('/api/v1/admin/pricing')->assertJsonPath('data.gaps.engine_cc', ['1301 - 1600']);

        $this->postJson('/api/v1/admin/pricing-factors', [
            'factor_type' => 'engine_cc',
            'min_value' => 1301,
            'max_value' => 1600,
            'multiplier' => 1.15,
        ])->assertCreated()->assertJsonPath('data.multiplier', '1.150');

        $this->getJson('/api/v1/admin/pricing')->assertJsonPath('data.gaps.engine_cc', []);
    }

    public function test_a_band_can_be_edited_in_place(): void
    {
        $band = PricingFactor::query()->ofType(PricingFactorType::ClaimsHistory)->whereNull('max_value')->firstOrFail();

        $this->putJson("/api/v1/admin/pricing-factors/{$band->id}", [
            'factor_type' => 'claims_history',
            'min_value' => 3,
            'max_value' => null,
            'multiplier' => 2,
        ])->assertOk()->assertJsonPath('data.multiplier', '2.000');
    }

    public function test_band_validation(): void
    {
        $this->postJson('/api/v1/admin/pricing-factors', [
            'factor_type' => 'engine_cc',
            'min_value' => 5000,
            'max_value' => 4000,
            'multiplier' => 0,
        ])
            ->assertUnprocessable()
            ->assertJsonValidationErrors(['max_value', 'multiplier']);
    }
}
