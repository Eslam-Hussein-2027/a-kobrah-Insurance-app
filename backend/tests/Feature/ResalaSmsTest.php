<?php

namespace Tests\Feature;

use App\Models\OtpCode;
use App\Services\Sms\Resala\ResalaClient;
use App\Services\Sms\Resala\ResalaErrorType;
use App\Services\Sms\Resala\ResalaException;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\Client\ConnectionException;
use Illuminate\Http\Client\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Tests\TestCase;

class ResalaSmsTest extends TestCase
{
    use RefreshDatabase;

    private const BASE = 'https://dev.resala.ly/api/v1';

    private const PIN_RESPONSE = [
        'id' => '9b1f5b7e-3f1a-4c2e-8a5e-6f3d2c1b0a9e',
        'pin' => '482913',
        'code' => '218',
        'region' => 'LY',
        'number' => '911234567',
        'content' => 'رمز التحقق: 482913 - العربية الكبرى للتأمين',
        'hit_count' => 0,
        'created_at' => '2026-11-28T12:00:00Z',
        'updated_at' => '2026-11-28T12:00:00Z',
        'sender_name' => 'AKOBRAH',
    ];

    protected function setUp(): void
    {
        parent::setUp();

        config([
            'insurance.sms.driver' => 'resala',
            'insurance.sms.resala.api_key' => 'rsl_test_key',
            'insurance.sms.resala.sender' => 'AKOBRAH',
            'insurance.sms.resala.test' => false,
        ]);
    }

    private function client(): ResalaClient
    {
        return $this->app->make(ResalaClient::class);
    }

    private function registration(array $overrides = []): array
    {
        return [
            'first_name' => 'محمد',
            'last_name' => 'الشريف',
            'phone' => '0911234567',
            'address' => 'بنغازي',
            'password' => 'secret12',
            'password_confirmation' => 'secret12',
            'device_name' => 'pixel-8',
            ...$overrides,
        ];
    }

    // ------------------------------------------------------------------ Client

    public function test_send_pin_posts_the_international_number_with_bearer_key_and_options(): void
    {
        Http::fake([self::BASE.'/pins*' => Http::response(self::PIN_RESPONSE, 201)]);

        $pin = $this->client()->sendPin('0911234567', 6);

        $this->assertSame('482913', $pin->pin);
        $this->assertSame('218911234567', $pin->phone);
        $this->assertSame('AKOBRAH', $pin->senderName);

        Http::assertSent(function (Request $request) {
            parse_str((string) parse_url($request->url(), PHP_URL_QUERY), $query);

            return $request->method() === 'POST'
                && str_starts_with($request->url(), self::BASE.'/pins?')
                && $request->hasHeader('Authorization', 'Bearer rsl_test_key')
                && $request['phone'] === '218911234567'
                && $query === ['service_name' => 'العربية الكبرى للتأمين', 'len' => '6', 'sender' => 'AKOBRAH'];
        });
    }

    public function test_test_mode_is_passed_to_resala(): void
    {
        config(['insurance.sms.resala.test' => true]);
        Http::fake([self::BASE.'/pins*' => Http::response(self::PIN_RESPONSE, 201)]);

        $this->client()->sendPin('0911234567');

        Http::assertSent(fn (Request $request) => str_contains($request->url(), 'test=1'));
    }

    public function test_numbers_are_sent_in_international_form(): void
    {
        foreach (['0911234567', '911234567', '+218 91 123 4567', '00218911234567', '218911234567'] as $phone) {
            $this->assertSame('218911234567', ResalaClient::international($phone), $phone);
        }
    }

    public function test_errors_are_typed_by_their_type_field_and_never_retried(): void
    {
        $cases = [
            [400, 'InsufficientCredit', ResalaErrorType::InsufficientCredit],
            [400, 'AccountExpired', ResalaErrorType::AccountExpired],
            [401, 'TokenExpired', ResalaErrorType::TokenExpired],
            [403, 'Forbidden', ResalaErrorType::Forbidden],
            [404, 'NotFound', ResalaErrorType::NotFound],
            [500, 'SomethingNew', ResalaErrorType::Unknown],
        ];

        $responses = Http::fakeSequence(self::BASE.'/*');
        foreach ($cases as [$status, $type]) {
            $responses->push(['type' => $type, 'message' => 'رسالة مترجمة'], $status);
        }

        foreach ($cases as [$status, $type, $expected]) {
            try {
                $this->client()->sendPin('0911234567');
                $this->fail("No exception for {$type}");
            } catch (ResalaException $exception) {
                $this->assertSame($expected, $exception->type, $type);
                $this->assertSame($status, $exception->status);
            }
        }

        // One request per send: failures are never retried.
        Http::assertSentCount(count($cases));
    }

    public function test_input_validation_carries_the_field_messages(): void
    {
        Http::fake([self::BASE.'/pins*' => Http::response([
            'type' => 'InputValidation',
            'message' => 'The given data was invalid.',
            'errors' => ['phone' => ['رقم الهاتف غير صالح.']],
        ], 422)]);

        try {
            $this->client()->sendPin('0951234567');
            $this->fail('No exception');
        } catch (ResalaException $exception) {
            $this->assertSame(ResalaErrorType::InputValidation, $exception->type);
            $this->assertSame(['phone' => ['رقم الهاتف غير صالح.']], $exception->errors);
        }
    }

    public function test_no_connection_is_its_own_error_type(): void
    {
        Http::fake(fn () => throw new ConnectionException('cURL error 6: Could not resolve host'));

        $this->expectExceptionObject(new ResalaException(ResalaErrorType::ConnectionFailed, 'cURL error 6: Could not resolve host'));

        $this->client()->sendPin('0911234567');
    }

    public function test_a_missing_key_fails_without_calling_resala(): void
    {
        config(['insurance.sms.resala.api_key' => null]);
        Http::fake();

        try {
            $this->client()->sendPin('0911234567');
            $this->fail('No exception');
        } catch (ResalaException $exception) {
            $this->assertSame(ResalaErrorType::Unauthorized, $exception->type);
        }

        Http::assertNothingSent();
    }

    public function test_send_template_reports_sent_skipped_numbers_and_sender_names(): void
    {
        Http::fake([self::BASE.'/messages/send-template*' => Http::response([
            'is_prod' => true,
            'total_messages' => 1,
            'total_free_messages' => 0,
            'total_sent_free_messages' => 0,
            'total_cost' => 0.05,
            'succeeded' => 1,
            'failed' => 0,
            'failed_numbers' => [],
            'invalid_numbers' => ['218951234567'],
            'sender_names' => ['libyana' => 'AKOBRAH', 'almadar' => 'AKOBRAH'],
            'sms_template_version' => ['id' => 'v', 'version_number' => 3, 'body' => 'وثيقتك $1 سارية حتى $2', 'status' => 'APPROVED'],
        ], 201)]);

        $result = $this->client()->sendTemplate('tpl-1', [
            ['phone' => '0911234567', '$1' => 'POL-2026-000001', '$2' => '2027-11-27'],
            ['phone' => '0951234567', '$1' => 'POL-2026-000002', '$2' => '2027-11-27'],
        ]);

        $this->assertSame(1, $result->succeeded);
        $this->assertSame(0.05, $result->totalCost);
        $this->assertSame(['218951234567'], $result->invalidNumbers);
        $this->assertSame(['libyana' => 'AKOBRAH', 'almadar' => 'AKOBRAH'], $result->senderNames);
        $this->assertSame('APPROVED', $result->templateStatus);

        Http::assertSent(fn (Request $request) => str_contains($request->url(), 'sms_template_id=tpl-1')
            && $request['records'][0] === ['phone' => '218911234567', '$1' => 'POL-2026-000001', '$2' => '2027-11-27']);
    }

    public function test_sent_view_lists_messages_with_paging(): void
    {
        Http::fake([self::BASE.'/sent-view*' => Http::response([
            'data' => [[
                'id' => '1f0c', 'code' => '218', 'region' => 'LY', 'number' => '911234567', 'content' => 'رمز التحقق: 482913',
                'source' => 'pin', 'status' => 'delivered', 'pages' => 1, 'env' => 'production',
                'created_at' => '2026-11-28T12:00:00Z', 'updated_at' => '2026-11-28T12:05:00Z',
            ]],
            'meta' => ['total' => 1, 'per_page' => 20, 'current_page' => 2, 'last_page' => 2],
        ])]);

        $page = $this->client()->sentMessages(page: 2, search: '0911');

        $this->assertSame('218911234567', $page->messages[0]->phone);
        $this->assertSame('delivered', $page->messages[0]->status);
        $this->assertSame([1, 2, 2], [$page->total, $page->currentPage, $page->lastPage]);
        Http::assertSent(fn (Request $request) => $request->method() === 'GET'
            && str_contains($request->url(), 'page=2') && str_contains($request->url(), 'q=0911'));
    }

    // ------------------------------------------------------------------ Sign-up codes through Resala

    public function test_sign_up_code_comes_from_resala_and_only_its_hash_is_kept(): void
    {
        Http::fake([self::BASE.'/pins*' => Http::response(self::PIN_RESPONSE, 201)]);

        $this->postJson('/api/v1/auth/register', $this->registration())->assertStatus(202);

        $this->assertNotSame('482913', OtpCode::query()->sole()->code_hash);
        $this->assertSame([], $this->sms->sent); // nothing through the log driver

        $this->postJson('/api/v1/auth/register', $this->registration(['code' => '482913']))
            ->assertCreated()
            ->assertJsonPath('data.user.phone', '0911234567');
    }

    public function test_an_empty_balance_is_logged_for_the_company_and_the_customer_can_retry_later(): void
    {
        Http::fake([self::BASE.'/pins*' => Http::response(['type' => 'InsufficientCredit', 'message' => 'رصيدك غير كافٍ'], 400)]);
        Log::spy();

        $this->postJson('/api/v1/auth/register', $this->registration())
            ->assertStatus(503)
            ->assertJsonPath('message', 'تعذّر إرسال رمز التحقق حاليًا. حاول بعد قليل، أو تواصل مع خدمة العملاء.');

        Log::shouldHaveReceived('critical')->once()->withArgs(
            fn (string $message, array $context) => str_contains($message, 'needs attention') && $context['type'] === 'InsufficientCredit',
        );
        $this->assertDatabaseCount('otp_codes', 0);
        Http::assertSentCount(1);
    }

    public function test_a_number_resala_cannot_text_is_a_phone_error(): void
    {
        Http::fake([self::BASE.'/pins*' => Http::response([
            'type' => 'InputValidation',
            'message' => 'invalid',
            'errors' => ['phone' => ['invalid']],
        ], 422)]);

        $this->postJson('/api/v1/auth/register', $this->registration())
            ->assertUnprocessable()
            ->assertJsonPath('errors.phone.0', 'لا يمكن إرسال رسالة إلى هذا الرقم. استخدم رقم ليبيانا أو المدار (091 أو 092 أو 093 أو 094).');
    }

    public function test_only_numbers_resala_can_text_are_accepted(): void
    {
        Http::fake();

        $this->postJson('/api/v1/auth/register', $this->registration(['phone' => '0951234567']))
            ->assertUnprocessable()
            ->assertJsonValidationErrors('phone');

        Http::assertNothingSent();
    }

    public function test_test_mode_logs_the_code_for_the_developer(): void
    {
        config(['insurance.sms.resala.test' => true]);
        Http::fake([self::BASE.'/pins*' => Http::response(self::PIN_RESPONSE, 201)]);
        Log::spy();

        $this->postJson('/api/v1/auth/register', $this->registration())->assertStatus(202);

        Log::shouldHaveReceived('info')->withArgs(fn (string $message, array $context) => $context === ['phone' => '0911234567', 'pin' => '482913']);
    }
}
