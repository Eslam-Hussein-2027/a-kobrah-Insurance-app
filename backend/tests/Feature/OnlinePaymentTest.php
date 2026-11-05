<?php

namespace Tests\Feature;

use App\Enums\PaymentStatus;
use App\Enums\PolicyStatus;
use App\Jobs\GeneratePolicyPdf;
use App\Models\Payment;
use App\Models\Policy;
use App\Models\User;
use App\Models\Vehicle;
use App\Services\Payments\SimulatorGateway;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Queue;
use Illuminate\Support\Facades\URL;
use Illuminate\Testing\TestResponse;
use Tests\TestCase;

class OnlinePaymentTest extends TestCase
{
    use RefreshDatabase;

    private User $customer;

    private Policy $policy;

    protected function setUp(): void
    {
        parent::setUp();

        Queue::fake();
        $this->customer = $this->customer();
        $this->policy = Policy::factory()
            ->for(Vehicle::factory()->for($this->customer))
            ->create(['premium' => '1452.00']);
    }

    private function startPayment(): Payment
    {
        $id = $this->actingAsUser($this->customer)
            ->postJson("/api/v1/policies/{$this->policy->id}/pay-online")
            ->assertCreated()
            ->json('data.id');

        return Payment::query()->findOrFail($id);
    }

    private function completeOnSimulator(Payment $payment, string $outcome): TestResponse
    {
        $url = URL::temporarySignedRoute('payments.simulator.complete', now()->addMinutes(5), [
            'payment' => $payment->id,
            'reference' => $payment->gateway_ref,
        ]);

        return $this->post($url, ['outcome' => $outcome]);
    }

    public function test_customer_starts_an_online_payment_and_gets_a_checkout_link(): void
    {
        $this->actingAsUser($this->customer)
            ->postJson("/api/v1/policies/{$this->policy->id}/pay-online")
            ->assertCreated()
            ->assertJsonPath('data.status.value', 'PENDING')
            ->assertJsonPath('data.method.value', 'ONLINE')
            ->assertJsonPath('data.gateway', 'simulator')
            ->assertJsonPath('data.amount', '1452.00');

        $payment = Payment::query()->sole();
        $this->assertStringContainsString('/payments/simulator/'.$payment->id, $payment->checkout_url);
        $this->get($payment->checkout_url)->assertOk()->assertSee('دفع ناجح')->assertSee($this->policy->policy_no);
    }

    public function test_successful_payment_activates_the_policy(): void
    {
        $payment = $this->startPayment();

        $this->completeOnSimulator($payment, 'paid')->assertRedirect();

        $this->assertSame(PaymentStatus::Paid, $payment->refresh()->status);
        $this->assertNotNull($payment->paid_at);
        $this->assertFalse($payment->requires_refund);
        $this->assertSame(PolicyStatus::Active, $this->policy->refresh()->status);
        Queue::assertPushed(GeneratePolicyPdf::class);

        $this->actingAsUser($this->customer)
            ->getJson("/api/v1/payments/{$payment->id}")
            ->assertOk()
            ->assertJsonPath('data.status.value', 'PAID')
            ->assertJsonPath('data.policy.status.value', 'ACTIVE')
            ->assertJsonMissingPath('data.checkout_url');
    }

    public function test_result_page_tells_the_customer_what_happened(): void
    {
        $payment = $this->startPayment();

        $this->followingRedirects()
            ->post(URL::temporarySignedRoute('payments.simulator.complete', now()->addMinutes(5), [
                'payment' => $payment->id,
                'reference' => $payment->gateway_ref,
            ]), ['outcome' => 'paid'])
            ->assertOk()
            ->assertSee('تم الدفع بنجاح');
    }

    public function test_declined_payment_keeps_the_policy_pending_and_can_be_retried(): void
    {
        $payment = $this->startPayment();

        $this->completeOnSimulator($payment, 'failed');

        $this->assertSame(PaymentStatus::Failed, $payment->refresh()->status);
        $this->assertSame('declined', $payment->failure_reason);
        $this->assertSame(PolicyStatus::PendingPayment, $this->policy->refresh()->status);

        $this->startPayment();
        $this->assertSame(2, $this->policy->payments()->count());
    }

    public function test_starting_again_closes_the_previous_attempt(): void
    {
        $first = $this->startPayment();
        $second = $this->startPayment();

        $this->assertSame(PaymentStatus::Failed, $first->refresh()->status);
        $this->assertSame('superseded', $first->failure_reason);
        $this->assertSame(PaymentStatus::Pending, $second->refresh()->status);
    }

    public function test_webhook_re_fetches_the_status_and_is_idempotent(): void
    {
        $payment = $this->startPayment();
        app(SimulatorGateway::class)->record($payment, true);

        $this->postJson('/api/v1/payments/webhook/simulator', ['reference' => $payment->gateway_ref])->assertOk();
        $this->postJson('/api/v1/payments/webhook/simulator', ['reference' => $payment->gateway_ref])->assertOk();

        $this->assertSame(PaymentStatus::Paid, $payment->refresh()->status);
        $this->assertSame(PolicyStatus::Active, $this->policy->refresh()->status);
        Queue::assertPushed(GeneratePolicyPdf::class, 1);
    }

    public function test_webhook_alone_cannot_mark_a_payment_as_paid(): void
    {
        $payment = $this->startPayment();

        // Attacker posts a "paid" callback, but the provider says nothing was paid.
        $this->postJson('/api/v1/payments/webhook/simulator', ['reference' => $payment->gateway_ref, 'status' => 'paid'])->assertOk();

        $this->assertSame(PaymentStatus::Pending, $payment->refresh()->status);
        $this->assertSame(PolicyStatus::PendingPayment, $this->policy->refresh()->status);
    }

    public function test_unknown_gateway_or_reference_is_ignored(): void
    {
        $this->postJson('/api/v1/payments/webhook/unknown', ['reference' => 'x'])->assertNotFound();
        $this->postJson('/api/v1/payments/webhook/simulator', ['reference' => 'SIM-NOPE'])->assertOk();
    }

    public function test_amount_mismatch_is_not_accepted(): void
    {
        $payment = $this->startPayment();
        Cache::put('payment-simulator:'.$payment->gateway_ref, ['status' => 'paid', 'amount' => '10.00']);

        $this->actingAsUser($this->customer)->getJson("/api/v1/payments/{$payment->id}")->assertOk();

        $payment->refresh();
        $this->assertSame(PaymentStatus::Failed, $payment->status);
        $this->assertSame('amount_mismatch', $payment->failure_reason);
        $this->assertTrue($payment->requires_refund);
        $this->assertSame(PolicyStatus::PendingPayment, $this->policy->refresh()->status);
    }

    public function test_online_payment_completed_after_office_payment_is_flagged_for_refund(): void
    {
        $payment = $this->startPayment();

        $this->actingAsUser($this->admin())
            ->postJson("/api/v1/admin/policies/{$this->policy->id}/confirm-office-payment")
            ->assertOk();
        $this->assertSame('paid_at_office', $payment->refresh()->failure_reason);

        // The customer still had the payment page open and paid there too.
        app(SimulatorGateway::class)->record($payment, true);
        $this->postJson('/api/v1/payments/webhook/simulator', ['reference' => $payment->gateway_ref])->assertOk();

        $payment->refresh();
        $this->assertSame(PaymentStatus::Paid, $payment->status);
        $this->assertTrue($payment->requires_refund);
        $this->assertSame(PolicyStatus::Active, $this->policy->refresh()->status);
    }

    public function test_only_the_owner_can_pay_and_only_while_pending(): void
    {
        $this->actingAsUser($this->customer())
            ->postJson("/api/v1/policies/{$this->policy->id}/pay-online")
            ->assertForbidden();

        $this->policy->update(['status' => PolicyStatus::Active]);
        $this->actingAsUser($this->customer)
            ->postJson("/api/v1/policies/{$this->policy->id}/pay-online")
            ->assertUnprocessable()
            ->assertJsonPath('message', 'هذه الوثيقة ليست بانتظار الدفع.');
    }

    public function test_customer_cannot_see_someone_elses_payment(): void
    {
        $payment = $this->startPayment();

        $this->actingAsUser($this->customer())->getJson("/api/v1/payments/{$payment->id}")->assertForbidden();
    }

    public function test_simulator_pages_require_a_valid_signature(): void
    {
        $payment = $this->startPayment();

        $this->get("/payments/simulator/{$payment->id}?reference={$payment->gateway_ref}")->assertForbidden();
    }
}
