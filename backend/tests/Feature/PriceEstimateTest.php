<?php

namespace Tests\Feature;

use App\Models\User;
use Carbon\CarbonImmutable;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

/**
 * "Know the price": same tariff as real quotes (fixture bands in TestCase::seedPricing).
 */
class PriceEstimateTest extends TestCase
{
    use RefreshDatabase;

    private User $customer;

    protected function setUp(): void
    {
        parent::setUp();

        $this->travelTo(CarbonImmutable::parse('2026-11-24 10:00:00'));
        $this->seedPricing();
        $this->customer = $this->customer();
    }

    public function test_estimate_uses_the_compulsory_coverage_by_default(): void
    {
        // 2021 → 5 years → ×1.100, 1600cc → ×1.100, no claims → ×1.000 ⇒ 1200 × 1.21 = 1452.00
        $this->actingAsUser($this->customer)
            ->postJson('/api/v1/quotes/estimate', ['manufacture_year' => 2021, 'engine_cc' => 1600])
            ->assertOk()
            ->assertJsonPath('data.vehicle', null)
            ->assertJsonPath('data.coverage_type.code', 'THIRD_PARTY')
            ->assertJsonPath('data.base_price', '1200.00')
            ->assertJsonPath('data.factors.0.input', 5)
            ->assertJsonPath('data.factors.0.multiplier', '1.100')
            ->assertJsonPath('data.factors.1.input', 1600)
            ->assertJsonPath('data.premium', '1452.00');
    }

    public function test_arabic_digits_are_accepted(): void
    {
        // 2010 → 16 years → ×1.400, 2700cc → ×1.450 ⇒ 1200 × 2.03 = 2436.00
        $this->actingAsUser($this->customer)
            ->postJson('/api/v1/quotes/estimate', ['manufacture_year' => '٢٠١٠', 'engine_cc' => '٢٧٠٠'])
            ->assertOk()
            ->assertJsonPath('data.premium', '2436.00');
    }

    public function test_inputs_are_validated(): void
    {
        $this->actingAsUser($this->customer)
            ->postJson('/api/v1/quotes/estimate', ['manufacture_year' => 1800, 'engine_cc' => 5])
            ->assertUnprocessable()
            ->assertJsonValidationErrors(['manufacture_year', 'engine_cc']);
    }

    public function test_guests_cannot_estimate(): void
    {
        $this->postJson('/api/v1/quotes/estimate', ['manufacture_year' => 2021, 'engine_cc' => 1600])
            ->assertUnauthorized();
    }
}
