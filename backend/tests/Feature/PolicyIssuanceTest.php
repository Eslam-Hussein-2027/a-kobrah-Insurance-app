<?php

namespace Tests\Feature;

use App\Enums\PaymentMethod;
use App\Enums\PaymentStatus;
use App\Enums\PolicyStatus;
use App\Jobs\GeneratePolicyPdf;
use App\Models\CoverageType;
use App\Models\Policy;
use App\Models\User;
use App\Models\Vehicle;
use Carbon\CarbonImmutable;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Queue;
use Illuminate\Testing\TestResponse;
use Tests\TestCase;

class PolicyIssuanceTest extends TestCase
{
    use RefreshDatabase;

    private User $customer;

    private Vehicle $vehicle;

    private CoverageType $comprehensive;

    protected function setUp(): void
    {
        parent::setUp();

        $this->travelTo(CarbonImmutable::parse('2026-06-01 10:00:00'));
        $this->seedPricing();

        $this->customer = $this->customer();
        // age 6 → 1.1, 1600cc → 1.1 ⇒ comprehensive premium 7865.00
        $this->vehicle = Vehicle::factory()->for($this->customer)->create(['year' => 2020, 'engine_cc' => 1600]);
        $this->comprehensive = CoverageType::query()->where('code', CoverageType::COMPREHENSIVE)->firstOrFail();
    }

    private function createPolicy(array $overrides = []): TestResponse
    {
        return $this->actingAsUser($this->customer)->postJson('/api/v1/policies', [
            'vehicle_id' => $this->vehicle->id,
            'coverage_type_id' => $this->comprehensive->id,
            ...$overrides,
        ]);
    }

    public function test_customer_creates_a_pending_policy_with_server_side_premium(): void
    {
        $this->createPolicy(['premium' => 1, 'start_date' => '2026-06-10'])
            ->assertCreated()
            ->assertJsonPath('data.policy_no', 'POL-2026-000001')
            ->assertJsonPath('data.status.value', 'PENDING_PAYMENT')
            ->assertJsonPath('data.status.label', 'بانتظار الدفع')
            ->assertJsonPath('data.premium', '7865.00')
            ->assertJsonPath('data.start_date', '2026-06-10')
            ->assertJsonPath('data.end_date', '2027-06-09')
            ->assertJsonPath('data.can_download_pdf', false)
            ->assertJsonMissingPath('data.pdf_url');

        $policy = Policy::query()->firstOrFail();
        $this->assertSame('7865.00', $policy->pricing_snapshot['premium']);
        $this->assertCount(3, $policy->pricing_snapshot['factors']);
    }

    public function test_policy_numbers_are_sequential_per_year(): void
    {
        $this->createPolicy()->assertJsonPath('data.policy_no', 'POL-2026-000001');

        $secondVehicle = Vehicle::factory()->for($this->customer)->create();
        $this->createPolicy(['vehicle_id' => $secondVehicle->id])->assertJsonPath('data.policy_no', 'POL-2026-000002');

        $this->travelTo(CarbonImmutable::parse('2027-01-02 09:00:00'));
        $thirdVehicle = Vehicle::factory()->for($this->customer)->create();
        $this->createPolicy(['vehicle_id' => $thirdVehicle->id])->assertJsonPath('data.policy_no', 'POL-2027-000001');
    }

    public function test_kyc_documents_are_required_before_issuing(): void
    {
        $this->customer->forceFill(['license_image' => null])->save();

        $this->createPolicy()
            ->assertUnprocessable()
            ->assertJsonPath('message', 'يرجى رفع صورة إثبات الهوية ورخصة القيادة قبل إصدار الوثيقة.');
    }

    public function test_overlapping_policies_for_the_same_vehicle_are_rejected(): void
    {
        $this->createPolicy()->assertCreated();

        $this->createPolicy(['start_date' => '2026-07-15'])
            ->assertUnprocessable()
            ->assertJsonPath('message', 'توجد وثيقة سارية أو بانتظار الدفع لهذه المركبة في نفس الفترة.');
    }

    public function test_cancelled_policy_frees_the_period(): void
    {
        $policyId = $this->createPolicy()->json('data.id');

        $this->postJson("/api/v1/policies/{$policyId}/cancel")
            ->assertOk()
            ->assertJsonPath('data.status.value', 'CANCELLED');

        $this->createPolicy()->assertCreated();
    }

    public function test_start_date_cannot_be_in_the_past(): void
    {
        $this->createPolicy(['start_date' => '2026-05-31'])
            ->assertUnprocessable()
            ->assertJsonPath('errors.start_date.0', 'تاريخ بداية الوثيقة لا يمكن أن يكون في الماضي.');
    }

    public function test_customer_cannot_insure_someone_elses_vehicle(): void
    {
        $this->createPolicy(['vehicle_id' => Vehicle::factory()->create()->id])->assertForbidden();
    }

    public function test_admin_confirms_office_payment_and_policy_becomes_active(): void
    {
        Queue::fake();
        $policyId = $this->createPolicy()->json('data.id');
        $admin = $this->admin();

        $this->actingAsUser($admin)
            ->postJson("/api/v1/admin/policies/{$policyId}/confirm-office-payment", ['reference' => 'RCPT-7781'])
            ->assertOk()
            ->assertJsonPath('data.status.value', 'ACTIVE')
            ->assertJsonPath('data.can_download_pdf', true)
            ->assertJsonPath('message', 'تم تأكيد الدفع وتفعيل الوثيقة.');

        $policy = Policy::query()->findOrFail($policyId);
        $this->assertSame(PolicyStatus::Active, $policy->status);
        $this->assertNotNull($policy->issued_at);

        $payment = $policy->payments()->sole();
        $this->assertSame(PaymentMethod::Office, $payment->method);
        $this->assertSame(PaymentStatus::Paid, $payment->status);
        $this->assertSame('7865.00', $payment->amount);
        $this->assertSame($admin->id, $payment->confirmed_by);
        $this->assertSame('RCPT-7781', $payment->gateway_ref);

        Queue::assertPushed(GeneratePolicyPdf::class, fn (GeneratePolicyPdf $job) => $job->policyId === $policyId);
    }

    public function test_late_payment_moves_the_start_date_to_today_and_keeps_full_term(): void
    {
        Queue::fake();
        $policyId = $this->createPolicy()->json('data.id'); // starts 2026-06-01

        $this->travelTo(CarbonImmutable::parse('2026-06-05 12:00:00'));

        $this->actingAsUser($this->admin())
            ->postJson("/api/v1/admin/policies/{$policyId}/confirm-office-payment")
            ->assertOk()
            ->assertJsonPath('data.start_date', '2026-06-05')
            ->assertJsonPath('data.end_date', '2027-06-04');
    }

    public function test_payment_cannot_be_confirmed_twice(): void
    {
        Queue::fake();
        $policyId = $this->createPolicy()->json('data.id');
        $this->actingAsUser($this->admin());

        $this->postJson("/api/v1/admin/policies/{$policyId}/confirm-office-payment")->assertOk();
        $this->postJson("/api/v1/admin/policies/{$policyId}/confirm-office-payment")
            ->assertUnprocessable()
            ->assertJsonPath('message', 'هذه الوثيقة ليست بانتظار الدفع.');

        $this->assertDatabaseCount('payments', 1);
    }

    public function test_only_admins_can_confirm_payments(): void
    {
        $policyId = $this->createPolicy()->json('data.id');

        $this->postJson("/api/v1/admin/policies/{$policyId}/confirm-office-payment")->assertForbidden();
    }

    public function test_active_policy_cannot_be_cancelled_by_customer(): void
    {
        $policy = Policy::factory()->active()->for($this->vehicle)->create();

        $this->actingAsUser($this->customer)
            ->postJson("/api/v1/policies/{$policy->id}/cancel")
            ->assertUnprocessable();
    }

    public function test_customer_sees_only_own_policies_and_can_filter_by_status(): void
    {
        Policy::factory()->active()->for($this->vehicle)->create();
        Policy::factory()->expired()->for($this->vehicle)->create();
        Policy::factory()->active()->create(); // another customer

        $this->actingAsUser($this->customer)->getJson('/api/v1/policies')
            ->assertOk()
            ->assertJsonCount(2, 'data');

        $this->getJson('/api/v1/policies?status=ACTIVE')
            ->assertOk()
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.status.value', 'ACTIVE')
            ->assertJsonPath('data.0.vehicle.id', $this->vehicle->id);
    }

    public function test_customer_cannot_view_another_customers_policy(): void
    {
        $policy = Policy::factory()->active()->create();

        $this->actingAsUser($this->customer)
            ->getJson("/api/v1/policies/{$policy->id}")
            ->assertForbidden()
            ->assertJsonPath('message', 'هذه الوثيقة غير مسجلة باسمك.');
    }
}
