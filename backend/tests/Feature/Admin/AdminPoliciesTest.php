<?php

namespace Tests\Feature\Admin;

use App\Enums\PaymentMethod;
use App\Enums\PaymentStatus;
use App\Models\Payment;
use App\Models\Policy;
use App\Models\Vehicle;
use Carbon\CarbonImmutable;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

class AdminPoliciesTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        $this->travelTo(CarbonImmutable::parse('2026-06-15 10:00:00'));
        $this->actingAsUser($this->admin());
    }

    public function test_dashboard_stats(): void
    {
        $active = Policy::factory()->active()->count(2)->create(['premium' => '1000.00']);
        Policy::factory()->create(); // pending
        Policy::factory()->cancelled()->create();

        Payment::query()->create(['policy_id' => $active[0]->id, 'amount' => '1000.00', 'method' => PaymentMethod::Office, 'status' => PaymentStatus::Paid, 'paid_at' => now()]);
        Payment::query()->create(['policy_id' => $active[1]->id, 'amount' => '1000.00', 'method' => PaymentMethod::Online, 'gateway' => 'simulator', 'status' => PaymentStatus::Paid, 'paid_at' => now()->subMonth()]);
        Payment::query()->create(['policy_id' => $active[1]->id, 'amount' => '500.00', 'method' => PaymentMethod::Online, 'gateway' => 'simulator', 'status' => PaymentStatus::Failed]);

        $this->getJson('/api/v1/admin/stats')
            ->assertOk()
            ->assertJsonPath('data.policies.active', 2)
            ->assertJsonPath('data.policies.pending_payment', 1)
            ->assertJsonPath('data.policies.cancelled', 1)
            ->assertJsonPath('data.revenue.total', '2000.00')
            ->assertJsonPath('data.revenue.this_month', '1000.00')
            ->assertJsonPath('data.revenue.online', '1000.00')
            ->assertJsonPath('data.revenue.office', '1000.00')
            ->assertJsonPath('data.customers', 4)
            ->assertJsonCount(6, 'data.monthly')
            ->assertJsonPath('data.monthly.5.month', '2026-06')
            ->assertJsonPath('data.monthly.5.revenue', '1000.00')
            ->assertJsonPath('data.monthly.4.revenue', '1000.00');
    }

    public function test_policies_can_be_filtered_and_searched(): void
    {
        $customer = $this->customer(['name' => 'سالم الورفلي', 'phone' => '0925551111']);
        $target = Policy::factory()->for(Vehicle::factory()->for($customer)->state(['plate_no' => '7-445566']))->create(['policy_no' => 'POL-2026-000777']);
        Policy::factory()->active()->count(3)->create();

        $this->getJson('/api/v1/admin/policies?status=PENDING_PAYMENT')->assertJsonCount(1, 'data');
        $this->getJson('/api/v1/admin/policies?status=ACTIVE')->assertJsonCount(3, 'data');

        foreach (['000777', '445566', '0925551111', 'الورفلي'] as $term) {
            $this->getJson('/api/v1/admin/policies?search='.urlencode($term))
                ->assertOk()
                ->assertJsonCount(1, 'data')
                ->assertJsonPath('data.0.id', $target->id)
                ->assertJsonPath('data.0.customer.phone', '0925551111');
        }
    }

    public function test_policy_details_include_customer_and_payments(): void
    {
        $policy = Policy::factory()->active()->create();
        Payment::query()->create(['policy_id' => $policy->id, 'amount' => $policy->premium, 'method' => PaymentMethod::Office, 'status' => PaymentStatus::Paid, 'paid_at' => now(), 'gateway_ref' => 'RCPT-9']);

        $this->getJson("/api/v1/admin/policies/{$policy->id}")
            ->assertOk()
            ->assertJsonPath('data.customer.id', $policy->vehicle->user_id)
            ->assertJsonPath('data.payments.0.reference', 'RCPT-9')
            ->assertJsonPath('data.payments.0.method.value', 'OFFICE');
    }

    public function test_admin_prints_active_policies_only(): void
    {
        Storage::fake('local');
        $this->seedPricing();
        $active = Policy::factory()->active()->create();
        $pending = Policy::factory()->create();

        $response = $this->get("/api/v1/admin/policies/{$active->id}/pdf")->assertOk()->assertHeader('Content-Type', 'application/pdf');
        $this->assertStringStartsWith('%PDF-', $response->streamedContent());

        $this->getJson("/api/v1/admin/policies/{$pending->id}/pdf")->assertForbidden();
    }

    public function test_admin_cancels_a_pending_policy(): void
    {
        $policy = Policy::factory()->create();

        $this->postJson("/api/v1/admin/policies/{$policy->id}/cancel")
            ->assertOk()
            ->assertJsonPath('data.status.value', 'CANCELLED');
    }

    public function test_payments_list_filters_by_method_and_refund_flag(): void
    {
        $policy = Policy::factory()->active()->create();
        Payment::query()->create(['policy_id' => $policy->id, 'amount' => '1.00', 'method' => PaymentMethod::Office, 'status' => PaymentStatus::Paid]);
        Payment::query()->create(['policy_id' => $policy->id, 'amount' => '1.00', 'method' => PaymentMethod::Online, 'gateway' => 'simulator', 'status' => PaymentStatus::Paid, 'requires_refund' => true]);

        $this->getJson('/api/v1/admin/payments?method=ONLINE')->assertJsonCount(1, 'data');
        $this->getJson('/api/v1/admin/payments?requires_refund=1')
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.requires_refund', true);
    }
}
