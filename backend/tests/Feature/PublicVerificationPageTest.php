<?php

namespace Tests\Feature;

use App\Models\Policy;
use App\Models\Vehicle;
use App\Services\Policy\PolicyVerificationService;
use App\Support\PersonName;
use Carbon\CarbonImmutable;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

/**
 * The page opened by scanning the QR code on a printed policy (police, government bodies, companies).
 */
class PublicVerificationPageTest extends TestCase
{
    use RefreshDatabase;

    private Policy $policy;

    protected function setUp(): void
    {
        parent::setUp();

        $this->travelTo(CarbonImmutable::parse('2026-06-01 10:00:00'));
        $customer = $this->customer(['name' => 'محمد أحمد الورفلي']);
        $vehicle = Vehicle::factory()->for($customer)->create([
            'plate_no' => '5-123456',
            'make' => 'Toyota',
            'model' => 'Corolla',
            'vin' => 'JTDBR32E720123456',
        ]);
        $this->policy = Policy::factory()->active()->for($vehicle)->create(['policy_no' => 'POL-2026-000123']);
    }

    private function qrUrl(Policy $policy): string
    {
        return app(PolicyVerificationService::class)->url($policy);
    }

    public function test_qr_link_points_to_this_apps_verification_page(): void
    {
        $url = $this->qrUrl($this->policy);

        $this->assertMatchesRegularExpression('#/verify/POL-2026-000123/[a-f0-9]{20}$#', $url);
        $this->assertSame($url, $this->qrUrl($this->policy->fresh()), 'stable for the life of the printed policy');
    }

    public function test_scanning_a_valid_policy_shows_status_and_vehicle_for_comparison(): void
    {
        $this->get($this->qrUrl($this->policy))
            ->assertOk()
            ->assertHeader('Cache-Control', 'no-store, private')
            ->assertSee('الوثيقة سارية')
            ->assertSee('POL-2026-000123')
            ->assertSee('5-123456')
            ->assertSee('Toyota Corolla')
            ->assertSee('123456')                 // last VIN digits only
            ->assertDontSee('JTDBR32E720123456')  // full VIN is not published
            ->assertSee('محمد أ. ا.')
            ->assertDontSee('محمد أحمد الورفلي');  // full name is not published
    }

    public function test_a_forged_or_altered_qr_is_rejected(): void
    {
        $url = $this->qrUrl($this->policy);

        // Wrong token
        $this->get(preg_replace('#/[a-f0-9]{20}$#', '/'.str_repeat('a', 20), $url))
            ->assertNotFound()
            ->assertSee('لا توجد وثيقة بهذه البيانات')
            ->assertSee('رمز التحقق غير صحيح');

        // Valid-looking token copied onto another policy number
        $this->get(str_replace('POL-2026-000123', 'POL-2026-000124', $url))->assertNotFound();
    }

    public function test_tokens_depend_on_the_secret(): void
    {
        $before = $this->qrUrl($this->policy);

        config(['insurance.verification_secret' => 'another-secret']);

        $this->assertNotSame($before, $this->qrUrl($this->policy));
        $this->get($before)->assertNotFound();
    }

    public function test_expired_cancelled_and_unpaid_policies_are_clearly_labelled(): void
    {
        $this->policy->update(['status' => 'EXPIRED']);
        $this->get($this->qrUrl($this->policy))->assertOk()->assertSee('الوثيقة منتهية');

        $this->policy->update(['status' => 'ACTIVE', 'end_date' => '2026-05-31']);
        $this->get($this->qrUrl($this->policy))->assertSee('الوثيقة منتهية');

        $this->policy->update(['status' => 'CANCELLED']);
        $this->get($this->qrUrl($this->policy))->assertSee('الوثيقة ملغاة');

        $this->policy->update(['status' => 'PENDING_PAYMENT']);
        $this->get($this->qrUrl($this->policy))->assertSee('الوثيقة غير مفعّلة');
    }

    public function test_manual_form_by_policy_and_plate_number(): void
    {
        $this->get('/verify')->assertOk()->assertSee('التحقق من وثيقة تأمين');

        $this->get('/verify?policy_no=pol-2026-000123&plate_no='.urlencode('٥ ١٢٣٤٥٦'))
            ->assertOk()
            ->assertSee('الوثيقة سارية')
            ->assertDontSee('المؤمَّن له'); // the name is shown only to QR holders

        $this->get('/verify?policy_no=POL-2026-000123&plate_no=9-999999')->assertNotFound();

        $this->get('/verify?policy_no=123&plate_no=')
            ->assertUnprocessable()
            ->assertSee('رقم الوثيقة يجب أن يكون بالصيغة');
    }

    public function test_app_and_dashboard_receive_the_same_link_for_issued_policies_only(): void
    {
        $this->actingAsUser($this->policy->vehicle->user)
            ->getJson("/api/v1/policies/{$this->policy->id}")
            ->assertJsonPath('data.verification_url', $this->qrUrl($this->policy));

        $pending = Policy::factory()->for($this->policy->vehicle)->create();
        $this->getJson("/api/v1/policies/{$pending->id}")->assertJsonMissingPath('data.verification_url');
    }

    public function test_name_masking(): void
    {
        $this->assertSame('محمد أ. ع.', PersonName::mask('محمد  أحمد علي'));
        $this->assertSame('سالم', PersonName::mask('سالم'));
    }
}
