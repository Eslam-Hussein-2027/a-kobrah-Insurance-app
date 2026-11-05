<?php

namespace Tests\Feature;

use App\Enums\PricingFactorType;
use App\Models\CoverageType;
use App\Models\PricingFactor;
use Database\Seeders\CoverageTypeSeeder;
use Database\Seeders\PricingFactorSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

/**
 * Guards the production reference data (the company's tariff), not the pricing maths.
 */
class ReferenceDataSeederTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        $this->seed([CoverageTypeSeeder::class, PricingFactorSeeder::class]);
    }

    public function test_only_compulsory_insurance_is_offered(): void
    {
        $this->assertSame(
            [CoverageType::THIRD_PARTY],
            CoverageType::query()->active()->pluck('code')->all(),
        );

        $this->getJson('/api/v1/coverage-types')
            ->assertOk()
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.code', CoverageType::THIRD_PARTY)
            ->assertJsonPath('data.0.name', 'التأمين الإجباري (ضد الغير)');
    }

    public function test_seeding_is_idempotent(): void
    {
        $this->seed([CoverageTypeSeeder::class, PricingFactorSeeder::class]);

        $this->assertSame(2, CoverageType::query()->count());
        $this->assertSame(14, PricingFactor::query()->count());
    }

    /**
     * Every factor type must cover 0 → ∞ with no gaps or overlaps, otherwise some vehicles can't be quoted.
     */
    public function test_pricing_bands_cover_every_value_without_gaps_or_overlaps(): void
    {
        foreach (PricingFactorType::cases() as $type) {
            $bands = PricingFactor::query()->ofType($type)->orderBy('min_value')->get();

            $this->assertNotEmpty($bands, "{$type->value}: no bands");
            $this->assertSame(0, $bands->first()->min_value, "{$type->value}: must start at 0");
            $this->assertNull($bands->last()->max_value, "{$type->value}: last band must be open-ended");

            foreach ($bands->slice(1)->values() as $i => $band) {
                $previous = $bands[$i];
                $this->assertSame(
                    $previous->max_value + 1,
                    $band->min_value,
                    "{$type->value}: gap or overlap between {$previous->max_value} and {$band->min_value}",
                );
            }
        }
    }
}
