<?php

namespace Tests\Feature;

use App\Enums\PaymentStatus;
use App\Enums\PolicyStatus;
use App\Models\Payment;
use App\Models\Policy;
use App\Models\User;
use App\Models\Vehicle;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\Client\Request as HttpRequest;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Queue;
use Illuminate\Testing\TestResponse;
use Tests\TestCase;

/**
 * DPAY OTP flow, with the provider faked from its sandbox documentation:
 * open session → customer gets a code → verify → read the session (source of truth) → webhook.
 */
class DpayPaymentTest extends TestCase
{
    use RefreshDatabase;

    private const API = 'https://dpay.ly/api/sandbox/payment/sessions';

    private User $customer;

    private Policy $policy;

    protected function setUp(): void
    {
        parent::setUp();

        Queue::fake();
        config([
            'payments.default' => 'dpay',
            'payments.gateways.dpay.token' => 'sb_tk_test',
            'payments.gateways.dpay.webhook_secret' => 'whsec_test',
            'payments.gateways.dpay.sandbox' => true,
            'payments.gateways.dpay.pay_methods' => ['edfali', 'sadad'],
        ]);

        $this->customer = $this->customer(['phone' => '0911234567']);
        $this->policy = Policy::factory()
            ->for(Vehicle::factory()->for($this->customer))
            ->create(['premium' => '1452.00', 'policy_no' => 'POL-2026-000010']);
    }

    /**
     * @param  array<string, mixed>  $session  fields returned when reading the session
     */
    private function fakeDpay(array $session = ['status' => 'pending'], int $verifyStatus = 200): void
    {
        Http::fake([
            self::API.'/open' => Http::response([
                'message' => 'Payment session created successfully',
                'session_id' => 4021,
                'status' => 'pending',
                'amount' => 1452,
                'total' => 1452.00,
                'pay_method' => 'edfali',
                'sandbox' => true,
            ], 201),
            self::API.'/verify' => Http::response(['message' => 'ok'], $verifyStatus),
            self::API.'/4021' => Http::response(array_merge(['session_id' => 4021, 'amount' => 1452], $session)),
        ]);
    }

    private function start(array $body = ['phone' => '091-123-4567', 'pay_method' => 'edfali']): TestResponse
    {
        return $this->actingAsUser($this->customer)->postJson("/api/v1/policies/{$this->policy->id}/pay-online", $body);
    }

    private function confirm(int $paymentId, string $otp): TestResponse
    {
        return $this->postJson("/api/v1/payments/{$paymentId}/confirm", ['otp' => $otp]);
    }

    public function test_options_tell_the_app_to_ask_for_a_phone_and_code(): void
    {
        $this->actingAsUser($this->customer)
            ->getJson('/api/v1/payments/options')
            ->assertOk()
            ->assertJsonPath('data.gateway', 'dpay')
            ->assertJsonPath('data.flow', 'otp')
            ->assertJsonPath('data.methods.0.value', 'edfali')
            ->assertJsonPath('data.methods.0.label', 'إدفعلي')
            ->assertJsonPath('data.methods.1.max', 5000);
    }

    public function test_starting_a_payment_opens_a_dpay_session(): void
    {
        $this->fakeDpay();

        $this->start()
            ->assertCreated()
            ->assertJsonPath('message', 'أرسلنا رمز تحقق إلى رقم هاتفك، أدخله لإتمام الدفع.')
            ->assertJsonPath('data.gateway', 'dpay')
            ->assertJsonPath('data.pay_method.label', 'إدفعلي')
            ->assertJsonPath('data.reference', '4021')
            ->assertJsonPath('data.requires_otp', true)
            ->assertJsonPath('data.checkout_url', null);

        Http::assertSent(fn (HttpRequest $request) => $request->url() === self::API.'/open'
            && $request->hasHeader('Authorization', 'Bearer sb_tk_test')
            && $request['pay_method'] === 'edfali'
            && $request['customer_mobile'] === '0911234567'
            && (float) $request['amount'] === 1452.0
            && $request['data']['policy_no'] === 'POL-2026-000010'
            && str_contains($request['return_url'], 'signature='));
    }

    public function test_the_right_code_pays_and_activates_the_policy(): void
    {
        $this->fakeDpay(['status' => 'paid']);
        $paymentId = $this->start()->json('data.id');

        $this->confirm($paymentId, '١١١١١١')
            ->assertOk()
            ->assertJsonPath('message', 'تم الدفع بنجاح وتفعيل الوثيقة.')
            ->assertJsonPath('data.status.value', 'PAID')
            ->assertJsonPath('data.requires_otp', false);

        Http::assertSent(fn (HttpRequest $request) => $request->url() === self::API.'/verify'
            && $request['session_id'] === 4021
            && $request['otp'] === '111111');

        $this->assertSame(PolicyStatus::Active, $this->policy->fresh()->status);
    }

    public function test_a_wrong_code_keeps_the_payment_open(): void
    {
        $this->fakeDpay(['status' => 'pending'], verifyStatus: 422);
        $paymentId = $this->start()->json('data.id');

        $this->confirm($paymentId, '123456')
            ->assertUnprocessable()
            ->assertJsonPath('message', 'رمز التحقق غير صحيح، حاول مرة أخرى.');

        $this->assertSame(PaymentStatus::Pending, Payment::query()->find($paymentId)->status);
    }

    public function test_a_declined_payment_is_recorded(): void
    {
        $this->fakeDpay(['status' => 'declined'], verifyStatus: 422);
        $paymentId = $this->start()->json('data.id');

        $this->confirm($paymentId, '000000')
            ->assertOk()
            ->assertJsonPath('message', 'لم تتم عملية الدفع، يمكنك المحاولة مرة أخرى.')
            ->assertJsonPath('data.status.value', 'FAILED')
            ->assertJsonPath('data.failure_reason', 'declined');

        $this->assertSame(PolicyStatus::PendingPayment, $this->policy->fresh()->status);
    }

    public function test_a_paid_amount_we_did_not_ask_for_is_flagged(): void
    {
        $this->fakeDpay(['status' => 'paid', 'amount' => 100]);
        $paymentId = $this->start()->json('data.id');

        $this->confirm($paymentId, '111111')->assertJsonPath('data.failure_reason', 'amount_mismatch');

        $this->assertTrue(Payment::query()->find($paymentId)->requires_refund);
        $this->assertSame(PolicyStatus::PendingPayment, $this->policy->fresh()->status);
    }

    public function test_signed_webhooks_trigger_a_status_check(): void
    {
        $this->fakeDpay(['status' => 'settled']);
        $this->start();
        $body = json_encode(['event' => 'payment.settled', 'session_id' => 4021]);

        $this->call('POST', '/api/v1/payments/webhook/dpay', [], [], [], [
            'CONTENT_TYPE' => 'application/json',
            'HTTP_X_DPAY_SIGNATURE' => hash_hmac('sha256', $body, 'whsec_test'),
        ], $body)->assertOk();

        $this->assertSame(PolicyStatus::Active, $this->policy->fresh()->status);
    }

    public function test_unsigned_or_forged_webhooks_are_ignored(): void
    {
        $this->fakeDpay(['status' => 'paid']);
        $this->start();
        $body = json_encode(['session_id' => 4021]);

        $this->call('POST', '/api/v1/payments/webhook/dpay', [], [], [], [
            'CONTENT_TYPE' => 'application/json',
            'HTTP_X_DPAY_SIGNATURE' => hash_hmac('sha256', $body, 'wrong-secret'),
        ], $body)->assertOk();

        $this->postJson('/api/v1/payments/webhook/dpay', ['session_id' => 4021])->assertOk();

        Http::assertNotSent(fn (HttpRequest $request) => $request->url() === self::API.'/4021');
        $this->assertSame(PolicyStatus::PendingPayment, $this->policy->fresh()->status);
    }

    public function test_phone_method_and_limits_are_checked_before_calling_dpay(): void
    {
        $this->fakeDpay();

        $this->start(['pay_method' => 'edfali'])
            ->assertUnprocessable()
            ->assertJsonPath('message', 'يرجى إدخال رقم الهاتف المسجّل في خدمة الدفع.');

        $this->start(['phone' => '0911234567', 'pay_method' => 'mobicash'])
            ->assertJsonPath('message', 'طريقة الدفع المختارة غير متاحة حاليًا.');

        $this->policy->update(['premium' => '6000.00']);
        $this->start(['phone' => '0911234567', 'pay_method' => 'sadad'])
            ->assertJsonPath('message', 'المبلغ خارج حدود طريقة الدفع المختارة (1 - 5,000 د.ل).');

        Http::assertNothingSent();
    }

    public function test_provider_outage_fails_cleanly(): void
    {
        Http::fake([self::API.'/open' => Http::response(['message' => 'down'], 500)]);

        $this->start()
            ->assertStatus(503)
            ->assertJsonPath('message', 'خدمة الدفع غير متاحة حاليًا، حاول بعد قليل.');

        $this->assertDatabaseHas('payments', ['policy_id' => $this->policy->id, 'status' => 'FAILED', 'failure_reason' => 'not_started']);
    }

    public function test_live_mode_uses_the_live_paths(): void
    {
        config(['payments.gateways.dpay.sandbox' => false, 'payments.gateways.dpay.token' => 'tk_live']);
        Http::fake(['https://dpay.ly/api/payment/sessions/open' => Http::response(['session_id' => 77], 201)]);

        $this->start()->assertCreated()->assertJsonPath('data.reference', '77');
    }
}
