<?php

namespace Tests\Feature\Auth;

use App\Enums\UserRole;
use App\Models\OtpCode;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

class OtpAuthenticationTest extends TestCase
{
    use RefreshDatabase;

    private const PHONE = '01012345678';

    public function test_it_sends_an_otp_and_stores_only_a_hash(): void
    {
        $this->postJson('/api/v1/auth/otp/send', ['phone' => self::PHONE])
            ->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.expires_in', 300);

        $code = $this->sms->lastCodeFor(self::PHONE);

        $this->assertNotNull($code);
        $this->assertDatabaseCount('otp_codes', 1);
        $this->assertNotSame($code, OtpCode::query()->first()->code_hash);
    }

    public function test_invalid_phone_is_rejected_with_an_arabic_message(): void
    {
        $this->postJson('/api/v1/auth/otp/send', ['phone' => '12345'])
            ->assertUnprocessable()
            ->assertJsonPath('success', false)
            ->assertJsonPath('message', 'البيانات المدخلة غير صحيحة.')
            ->assertJsonPath('errors.phone.0', 'رقم الهاتف غير صحيح، يجب أن يكون رقم موبايل مصري مكوّن من 11 رقماً (مثال: 01012345678).');
    }

    public function test_english_messages_are_returned_when_requested(): void
    {
        $this->postJson('/api/v1/auth/otp/send', [], ['Accept-Language' => 'en'])
            ->assertUnprocessable()
            ->assertJsonPath('message', 'The given data was invalid.')
            ->assertHeader('Content-Language', 'en');
    }

    public function test_arabic_indic_digits_are_accepted(): void
    {
        $this->postJson('/api/v1/auth/otp/send', ['phone' => '٠١٠١٢٣٤٥٦٧٨'])->assertOk();

        $this->assertNotNull($this->sms->lastCodeFor(self::PHONE));
    }

    public function test_resending_within_a_minute_is_rate_limited(): void
    {
        $this->postJson('/api/v1/auth/otp/send', ['phone' => self::PHONE])->assertOk();

        $this->postJson('/api/v1/auth/otp/send', ['phone' => self::PHONE])
            ->assertTooManyRequests()
            ->assertJsonPath('message', 'عدد كبير من المحاولات، يرجى المحاولة لاحقاً.');
    }

    public function test_new_phone_receives_registration_token_and_can_register(): void
    {
        $registrationToken = $this->verifyNewPhone();

        $response = $this->postJson('/api/v1/auth/register', [
            'registration_token' => $registrationToken,
            'name' => 'محمد أحمد',
            'national_id' => '29501011234567',
            'device_name' => 'pixel-8',
        ]);

        $response->assertCreated()
            ->assertJsonPath('data.token_type', 'Bearer')
            ->assertJsonPath('data.user.phone', self::PHONE)
            ->assertJsonPath('data.user.role.value', 'customer')
            ->assertJsonPath('data.user.kyc_completed', false);

        $user = User::query()->where('phone', self::PHONE)->firstOrFail();
        $this->assertTrue($user->hasRole(UserRole::Customer->value));

        $this->withToken($response->json('data.token'))
            ->getJson('/api/v1/auth/me')
            ->assertOk()
            ->assertJsonPath('data.national_id', '29501011234567');
    }

    public function test_registration_token_is_single_use(): void
    {
        $registrationToken = $this->verifyNewPhone();
        $payload = [
            'registration_token' => $registrationToken,
            'name' => 'محمد أحمد',
            'national_id' => '29501011234567',
            'device_name' => 'pixel-8',
        ];

        $this->postJson('/api/v1/auth/register', $payload)->assertCreated();

        $this->postJson('/api/v1/auth/register', [...$payload, 'national_id' => '29501011234568'])
            ->assertUnprocessable()
            ->assertJsonValidationErrors('registration_token');
    }

    public function test_registration_stores_documents_on_private_disk_behind_signed_urls(): void
    {
        Storage::fake('local');
        $registrationToken = $this->verifyNewPhone();

        $response = $this->post('/api/v1/auth/register', [
            'registration_token' => $registrationToken,
            'name' => 'محمد أحمد',
            'national_id' => '29501011234567',
            'device_name' => 'pixel-8',
            'id_image' => UploadedFile::fake()->image('id.jpg', 800, 500),
            'license_image' => UploadedFile::fake()->image('license.png', 800, 500),
        ])->assertCreated()->assertJsonPath('data.user.kyc_completed', true);

        $user = User::query()->where('phone', self::PHONE)->firstOrFail();
        Storage::disk('local')->assertExists([$user->id_image, $user->license_image]);

        $signedUrl = $response->json('data.user.documents.id_image.url');
        $this->get($signedUrl)->assertOk();

        // Tampered / unsigned URLs are refused.
        $this->getJson(strtok($signedUrl, '?'))->assertForbidden();
        $this->getJson($signedUrl.'x')->assertForbidden()
            ->assertJsonPath('message', 'الرابط غير صالح أو منتهي الصلاحية.');
    }

    public function test_upload_rejects_non_image_files(): void
    {
        $user = $this->customer();

        $this->actingAsUser($user)
            ->post('/api/v1/me/documents', ['id_image' => UploadedFile::fake()->create('id.pdf', 100, 'application/pdf')])
            ->assertUnprocessable()
            ->assertJsonValidationErrors('id_image');
    }

    public function test_existing_user_logs_in_with_otp(): void
    {
        User::factory()->create(['phone' => self::PHONE]);

        $this->postJson('/api/v1/auth/otp/send', ['phone' => self::PHONE])->assertOk();

        $this->postJson('/api/v1/auth/otp/verify', [
            'phone' => self::PHONE,
            'code' => $this->sms->lastCodeFor(self::PHONE),
            'device_name' => 'iphone',
        ])
            ->assertOk()
            ->assertJsonPath('data.is_new_user', false)
            ->assertJsonStructure(['data' => ['token', 'user' => ['id', 'phone', 'role', 'documents']]]);
    }

    public function test_code_is_locked_after_max_wrong_attempts(): void
    {
        User::factory()->create(['phone' => self::PHONE]);
        $this->postJson('/api/v1/auth/otp/send', ['phone' => self::PHONE]);
        $code = $this->sms->lastCodeFor(self::PHONE);
        $wrong = $code === '000000' ? '111111' : '000000';

        foreach (range(1, 5) as $_) {
            $this->postJson('/api/v1/auth/otp/verify', ['phone' => self::PHONE, 'code' => $wrong, 'device_name' => 'x'])
                ->assertUnprocessable()
                ->assertJsonPath('errors.code.0', 'رمز التحقق غير صحيح أو منتهي الصلاحية.');
        }

        // Even the right code no longer works.
        $this->postJson('/api/v1/auth/otp/verify', ['phone' => self::PHONE, 'code' => $code, 'device_name' => 'x'])
            ->assertUnprocessable();
    }

    public function test_code_cannot_be_reused(): void
    {
        User::factory()->create(['phone' => self::PHONE]);
        $this->postJson('/api/v1/auth/otp/send', ['phone' => self::PHONE]);
        $payload = ['phone' => self::PHONE, 'code' => $this->sms->lastCodeFor(self::PHONE), 'device_name' => 'x'];

        $this->postJson('/api/v1/auth/otp/verify', $payload)->assertOk();
        $this->postJson('/api/v1/auth/otp/verify', $payload)->assertUnprocessable();
    }

    public function test_expired_code_is_rejected(): void
    {
        User::factory()->create(['phone' => self::PHONE]);
        $this->postJson('/api/v1/auth/otp/send', ['phone' => self::PHONE]);

        $this->travel(6)->minutes();

        $this->postJson('/api/v1/auth/otp/verify', [
            'phone' => self::PHONE,
            'code' => $this->sms->lastCodeFor(self::PHONE),
            'device_name' => 'x',
        ])->assertUnprocessable();
    }

    public function test_disabled_account_cannot_log_in(): void
    {
        User::factory()->inactive()->create(['phone' => self::PHONE]);
        $this->postJson('/api/v1/auth/otp/send', ['phone' => self::PHONE]);

        $this->postJson('/api/v1/auth/otp/verify', [
            'phone' => self::PHONE,
            'code' => $this->sms->lastCodeFor(self::PHONE),
            'device_name' => 'x',
        ])->assertUnprocessable()->assertJsonValidationErrors('phone');
    }

    public function test_logout_revokes_the_current_token(): void
    {
        User::factory()->create(['phone' => self::PHONE]);
        $this->postJson('/api/v1/auth/otp/send', ['phone' => self::PHONE]);
        $token = $this->postJson('/api/v1/auth/otp/verify', [
            'phone' => self::PHONE,
            'code' => $this->sms->lastCodeFor(self::PHONE),
            'device_name' => 'x',
        ])->json('data.token');

        $this->withToken($token)->postJson('/api/v1/auth/logout')->assertOk();

        $this->assertDatabaseCount('personal_access_tokens', 0);
    }

    public function test_protected_routes_return_json_401_in_arabic(): void
    {
        $this->get('/api/v1/auth/me')
            ->assertUnauthorized()
            ->assertExactJson(['success' => false, 'message' => 'يجب تسجيل الدخول أولاً.']);
    }

    private function verifyNewPhone(): string
    {
        $this->postJson('/api/v1/auth/otp/send', ['phone' => self::PHONE])->assertOk();

        return $this->postJson('/api/v1/auth/otp/verify', [
            'phone' => self::PHONE,
            'code' => $this->sms->lastCodeFor(self::PHONE),
            'device_name' => 'pixel-8',
        ])
            ->assertOk()
            ->assertJsonPath('data.is_new_user', true)
            ->json('data.registration_token');
    }
}
