<?php

namespace Tests\Feature;

use App\Enums\PersonRelationship;
use App\Enums\TravelZone;
use App\Models\InsuredPerson;
use App\Models\Policy;
use App\Models\TravelRate;
use App\Models\User;
use App\Models\Vehicle;
use App\Services\Policy\PolicyPdfService;
use App\Services\Policy\PolicyVerificationService;
use Carbon\CarbonImmutable;
use Database\Seeders\TravelRateSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Testing\TestResponse;
use Tests\TestCase;

/**
 * Travel tariff from TravelRateSeeder: schengen 15 days = 85.00 per traveller, arab 7 days = 35.00.
 */
class TravelInsuranceTest extends TestCase
{
    use RefreshDatabase;

    private User $customer;

    private InsuredPerson $ahmed;

    private InsuredPerson $sara;

    protected function setUp(): void
    {
        parent::setUp();

        $this->travelTo(CarbonImmutable::parse('2026-11-24 10:00:00'));
        $this->seed(TravelRateSeeder::class);

        $this->customer = $this->customer(['name' => 'أحمد الشريف']);
        $this->ahmed = InsuredPerson::factory()->for($this->customer)->create([
            'full_name' => 'أحمد الشريف', 'passport_no' => 'LY1234567', 'birth_date' => '1988-04-12',
        ]);
        $this->sara = InsuredPerson::factory()->for($this->customer)->create([
            'full_name' => 'سارة محمد', 'relationship' => PersonRelationship::Spouse, 'passport_no' => 'LY7654321',
        ]);
    }

    private function buy(array $overrides = []): TestResponse
    {
        return $this->actingAsUser($this->customer)->postJson('/api/v1/policies/travel', array_merge([
            'zone' => 'schengen',
            'days' => 15,
            'start_date' => '2026-12-01',
            'person_ids' => [$this->ahmed->id, $this->sara->id],
        ], $overrides));
    }

    public function test_options_list_zones_with_trip_lengths_and_prices(): void
    {
        $this->actingAsUser($this->customer)
            ->getJson('/api/v1/travel/options')
            ->assertOk()
            ->assertJsonCount(3, 'data.zones')
            ->assertJsonPath('data.zones.1.value', 'schengen')
            ->assertJsonPath('data.zones.1.label', 'أوروبا (شنغن)')
            ->assertJsonPath('data.zones.1.durations.1.days', 15)
            ->assertJsonPath('data.zones.1.durations.1.price_per_traveller', '85.00')
            ->assertJsonPath('data.max_travellers', 10);
    }

    public function test_quote_is_price_per_traveller_times_travellers(): void
    {
        $this->actingAsUser($this->customer)
            ->postJson('/api/v1/quotes/travel', ['zone' => 'schengen', 'days' => 15, 'travellers' => 3])
            ->assertOk()
            ->assertJsonPath('data.price_per_traveller', '85.00')
            ->assertJsonPath('data.premium', '255.00');
    }

    public function test_customer_buys_a_travel_policy_for_saved_persons(): void
    {
        $this->buy()
            ->assertCreated()
            ->assertJsonPath('data.product.value', 'travel')
            ->assertJsonPath('data.title', 'تأمين السفر - أوروبا (شنغن)')
            ->assertJsonPath('data.status.value', 'PENDING_PAYMENT')
            ->assertJsonPath('data.start_date', '2026-12-01')
            ->assertJsonPath('data.end_date', '2026-12-15')
            ->assertJsonPath('data.premium', '170.00')
            ->assertJsonPath('data.vehicle', null)
            ->assertJsonPath('data.travel.zone.value', 'schengen')
            ->assertJsonPath('data.travel.days', 15)
            ->assertJsonPath('data.travel.travellers.0.full_name', 'أحمد الشريف')
            ->assertJsonPath('data.travel.travellers.1.passport_no', 'LY7654321');

        $policy = Policy::query()->sole();
        $this->assertSame($this->customer->id, $policy->user_id);
        $this->assertSame('170.00', $policy->pricing_snapshot['premium']);
    }

    public function test_travellers_snapshot_survives_editing_the_person(): void
    {
        $this->buy()->assertCreated();

        $this->sara->update(['full_name' => 'اسم آخر']);
        $this->sara->delete();

        $this->getJson('/api/v1/policies/'.Policy::query()->value('id'))
            ->assertJsonPath('data.travel.travellers.1.full_name', 'سارة محمد');
    }

    public function test_every_traveller_needs_a_passport_number(): void
    {
        $this->sara->update(['passport_no' => null]);

        $this->buy()
            ->assertUnprocessable()
            ->assertJsonPath('message', 'يرجى إضافة رقم جواز السفر قبل الإصدار: سارة محمد');
    }

    public function test_only_the_customers_own_persons_can_travel(): void
    {
        $stranger = InsuredPerson::factory()->create();

        $this->buy(['person_ids' => [$this->ahmed->id, $stranger->id]])
            ->assertUnprocessable()
            ->assertJsonValidationErrors(['person_ids.1']);
    }

    public function test_trip_length_must_exist_in_the_tariff(): void
    {
        $this->buy(['days' => 10])
            ->assertUnprocessable()
            ->assertJsonPath('message', __('messages.travel.no_rate'));
    }

    public function test_start_date_cannot_be_in_the_past(): void
    {
        $this->buy(['start_date' => '2026-11-20'])
            ->assertUnprocessable()
            ->assertJsonValidationErrors(['start_date']);
    }

    public function test_late_payment_keeps_the_full_trip_length(): void
    {
        $policyId = $this->buy(['zone' => 'arab', 'days' => 7, 'start_date' => '2026-11-24'])->json('data.id');

        $this->travelTo(CarbonImmutable::parse('2026-11-26 09:00:00'));

        $this->actingAsUser($this->admin())
            ->postJson("/api/v1/admin/policies/{$policyId}/confirm-office-payment")
            ->assertOk()
            ->assertJsonPath('data.status.value', 'ACTIVE')
            ->assertJsonPath('data.start_date', '2026-11-26')
            ->assertJsonPath('data.end_date', '2026-12-02');
    }

    public function test_policies_list_mixes_products_and_can_be_filtered(): void
    {
        $this->buy()->assertCreated();
        Policy::factory()->for(Vehicle::factory()->for($this->customer))->create();

        $this->getJson('/api/v1/policies')->assertOk()->assertJsonCount(2, 'data');
        $this->getJson('/api/v1/policies?product=travel')
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.product.value', 'travel');
    }

    public function test_qr_page_shows_masked_travellers(): void
    {
        $policy = Policy::factory()->travel(TravelZone::Arab, 7)->active()->for($this->customer)->create();
        $policy->travellers()->create(['full_name' => 'سارة محمد علي', 'birth_date' => '1991-09-03', 'passport_no' => 'LY7654321']);

        $this->get(app(PolicyVerificationService::class)->url($policy))
            ->assertOk()
            ->assertSee('الوثيقة سارية')
            ->assertSee('تأمين السفر - الدول العربية')
            ->assertSee('سارة م. ع.')
            ->assertDontSee('سارة محمد علي')
            ->assertSee('•••••321')
            ->assertDontSee('LY7654321');
    }

    public function test_travel_policy_pdf_is_rendered(): void
    {
        $policy = Policy::factory()->travel()->active()->for($this->customer)->create();
        $policy->travellers()->create(['full_name' => 'أحمد الشريف', 'birth_date' => '1988-04-12', 'passport_no' => 'LY1234567']);

        $this->assertSame($this->customer->id, $policy->user_id);
        $this->assertStringStartsWith('%PDF', app(PolicyPdfService::class)->render($policy));
    }

    public function test_admin_finds_travel_policies_by_passport_number(): void
    {
        $this->buy()->assertCreated();

        $this->actingAsUser($this->admin())
            ->getJson('/api/v1/admin/policies?search=LY7654321')
            ->assertOk()
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.product.value', 'travel')
            ->assertJsonPath('data.0.customer.name', 'أحمد الشريف');
    }

    public function test_admin_manages_travel_prices(): void
    {
        $this->actingAsUser($this->admin());
        $rate = TravelRate::query()->where('zone', 'schengen')->where('days', 15)->sole();

        $this->getJson('/api/v1/admin/pricing')
            ->assertOk()
            ->assertJsonCount(12, 'data.travel_rates')
            ->assertJsonCount(3, 'data.travel_zones');

        $this->patchJson("/api/v1/admin/travel-rates/{$rate->id}", ['price' => 95])
            ->assertOk()
            ->assertJsonPath('data.price', '95.00');

        $this->postJson('/api/v1/admin/travel-rates', ['zone' => 'schengen', 'days' => 15, 'price' => 1])
            ->assertJsonValidationErrors(['days']);

        $this->postJson('/api/v1/admin/travel-rates', ['zone' => 'schengen', 'days' => 60, 'price' => 180])
            ->assertCreated();

        // Customers see the new price and trip length.
        $this->actingAsUser($this->customer)
            ->postJson('/api/v1/quotes/travel', ['zone' => 'schengen', 'days' => 60, 'travellers' => 2])
            ->assertJsonPath('data.premium', '360.00');
    }
}
