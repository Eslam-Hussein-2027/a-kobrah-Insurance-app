<?php

namespace Tests\Feature\Auth;

use App\Enums\UserRole;
use App\Models\OtpCode;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;
use Illuminate\Testing\TestResponse;
use Tests\TestCase;

class CustomerAuthTest extends TestCase
{
    use RefreshDatabase;

    private const PHONE = '0911234567';

    private function registration(array $overrides = []): array
    {
        return [
            'first_name' => 'محمد',
            'last_name' => 'الشريف',
            'phone' => self::PHONE,
            'address' => 'بنغازي - الفويهات',
            'password' => 'secret12',
            'password_confirmation' => 'secret12',
            'device_name' => 'pixel-8',
            ...$overrides,
        ];
    }

    private function register(array $overrides = []): TestResponse
    {
        return $this->postJson('/api/v1/auth/register', $this->registration($overrides));
    }

    private function login(string $phone, string $password): TestResponse
    {
        return $this->postJson('/api/v1/auth/login', ['phone' => $phone, 'password' => $password, 'device_name' => 'x']);
    }

    // ------------------------------------------------------------------ Registration

    public function test_registration_sends_an_sms_code_then_creates_the_account(): void
    {
        $this->register()
            ->assertStatus(202)
            ->assertJsonPath('data.verification_required', true)
            ->assertJsonPath('data.expires_in', 300)
            ->assertJsonPath('data.resend_after', 60);

        $this->assertDatabaseCount('users', 0);
        $code = $this->sms->lastCodeFor(self::PHONE);
        $this->assertNotSame($code, OtpCode::query()->first()->code_hash); // only a hash is stored

        $response = $this->register(['code' => $code])
            ->assertCreated()
            ->assertJsonPath('data.token_type', 'Bearer')
            ->assertJsonPath('data.user.name', 'محمد الشريف')
            ->assertJsonPath('data.user.phone', self::PHONE)
            ->assertJsonPath('data.user.address', 'بنغازي - الفويهات')
            ->assertJsonPath('data.user.role.value', 'customer')
            ->assertJsonPath('data.user.kyc_completed', false);

        $user = User::query()->where('phone', self::PHONE)->sole();
        $this->assertTrue($user->hasRole(UserRole::Customer->value));
        $this->assertNotNull($user->phone_verified_at);
        $this->assertTrue(Hash::check('secret12', $user->password));

        $this->withToken($response->json('data.token'))->getJson('/api/v1/auth/me')->assertOk();
    }

    public function test_without_phone_verification_the_account_is_created_at_once(): void
    {
        config(['insurance.auth.verify_phone_on_register' => false]);

        $this->register()->assertCreated()->assertJsonPath('data.user.phone', self::PHONE);

        $this->assertSame([], $this->sms->sent);
        $this->assertNull(User::query()->sole()->phone_verified_at);
    }

    public function test_a_wrong_code_creates_nothing_and_the_code_locks_after_five_tries(): void
    {
        $this->register()->assertStatus(202);
        $code = $this->sms->lastCodeFor(self::PHONE);
        $wrong = $code === '000000' ? '111111' : '000000';

        foreach (range(1, 5) as $_) {
            $this->register(['code' => $wrong])
                ->assertUnprocessable()
                ->assertJsonPath('errors.code.0', 'رمز التحقق غير صحيح أو منتهي الصلاحية.');
        }

        $this->register(['code' => $code])->assertUnprocessable();
        $this->assertDatabaseCount('users', 0);
    }

    public function test_an_expired_code_is_rejected(): void
    {
        $this->register();
        $this->travel(6)->minutes();

        $this->register(['code' => $this->sms->lastCodeFor(self::PHONE)])
            ->assertUnprocessable()
            ->assertJsonValidationErrors('code');
    }

    public function test_codes_are_limited_to_one_a_minute_per_phone(): void
    {
        $this->register()->assertStatus(202);

        $this->register()
            ->assertTooManyRequests()
            ->assertJsonPath('message', 'عدد كبير من المحاولات، يرجى المحاولة لاحقاً.');

        $this->travel(61)->seconds();
        $this->register()->assertStatus(202);
    }

    public function test_form_errors_are_in_arabic_and_checked_before_any_sms(): void
    {
        User::factory()->create(['phone' => self::PHONE]);

        $this->register(['password_confirmation' => 'other123', 'first_name' => ''])
            ->assertUnprocessable()
            ->assertJsonPath('errors.phone.0', 'رقم الهاتف مسجل بالفعل.')
            ->assertJsonPath('errors.password.0', 'تأكيد كلمة المرور غير مطابق.')
            ->assertJsonPath('errors.first_name.0', 'حقل الإسم مطلوب.');

        $this->register(['phone' => '12345'])
            ->assertJsonPath('errors.phone.0', 'رقم الهاتف غير صحيح، يجب أن يكون رقم هاتف محمول ليبي مكوّن من 10 أرقام (مثال: 0911234567).');

        $this->register(['phone' => '0921234567', 'password' => '123', 'password_confirmation' => '123'])
            ->assertJsonValidationErrors('password');

        $this->assertSame([], $this->sms->sent);
    }

    public function test_phone_notations_all_mean_the_same_number(): void
    {
        config(['insurance.auth.verify_phone_on_register' => false]);

        // Typed after the "+218" box: 9 digits without the leading zero.
        $this->register(['phone' => '911234567'])->assertCreated()->assertJsonPath('data.user.phone', self::PHONE);

        foreach (['+218 91-123 4567', '00218911234567', '٠٩١١٢٣٤٥٦٧', '911234567'] as $phone) {
            $this->login($phone, 'secret12')->assertOk();
        }
    }

    public function test_english_messages_are_returned_when_requested(): void
    {
        $this->postJson('/api/v1/auth/login', [], ['Accept-Language' => 'en'])
            ->assertUnprocessable()
            ->assertJsonPath('message', 'The given data was invalid.')
            ->assertHeader('Content-Language', 'en');
    }

    // ------------------------------------------------------------------ Login

    public function test_customer_logs_in_with_phone_and_password(): void
    {
        User::factory()->create(['phone' => self::PHONE, 'password' => 'secret12']);

        $this->login(self::PHONE, 'secret12')
            ->assertOk()
            ->assertJsonPath('message', 'تم تسجيل الدخول بنجاح.')
            ->assertJsonStructure(['data' => ['token', 'user' => ['id', 'phone', 'role', 'documents']]]);
    }

    public function test_wrong_password_unknown_phone_and_staff_get_the_same_message(): void
    {
        User::factory()->create(['phone' => self::PHONE, 'password' => 'secret12']);
        User::factory()->admin()->create(['phone' => '0910000001', 'password' => 'secret12']);

        foreach ([[self::PHONE, 'wrong-1'], ['0929999999', 'secret12'], ['0910000001', 'secret12']] as [$phone, $password]) {
            $this->login($phone, $password)
                ->assertUnprocessable()
                ->assertJsonPath('errors.phone.0', 'رقم الهاتف أو كلمة المرور غير صحيحة.');
        }
    }

    public function test_accounts_without_a_password_must_reset_it_first(): void
    {
        User::factory()->create(['phone' => self::PHONE, 'password' => null]);

        $this->login(self::PHONE, 'anything')->assertUnprocessable()->assertJsonValidationErrors('phone');
    }

    public function test_disabled_account_cannot_log_in(): void
    {
        User::factory()->inactive()->create(['phone' => self::PHONE, 'password' => 'secret12']);

        $this->login(self::PHONE, 'secret12')
            ->assertUnprocessable()
            ->assertJsonPath('errors.phone.0', 'هذا الحساب موقوف، يرجى التواصل مع خدمة العملاء.');
    }

    public function test_password_guessing_is_rate_limited(): void
    {
        User::factory()->create(['phone' => self::PHONE, 'password' => 'secret12']);

        foreach (range(1, 5) as $_) {
            $this->login(self::PHONE, 'wrong-1')->assertUnprocessable();
        }

        $this->login(self::PHONE, 'secret12')->assertTooManyRequests();
    }

    // ------------------------------------------------------------------ Passwords

    public function test_forgotten_password_is_reset_with_an_sms_code(): void
    {
        $user = User::factory()->create(['phone' => self::PHONE, 'password' => 'old-pass1']);
        $user->createToken('old-phone');

        $this->postJson('/api/v1/auth/password/forgot', ['phone' => self::PHONE])
            ->assertOk()
            ->assertJsonPath('message', 'إذا كان الرقم مسجلًا لدينا فسيصلك رمز تحقق برسالة نصية خلال لحظات.');

        $this->postJson('/api/v1/auth/password/reset', [
            'phone' => self::PHONE,
            'code' => $this->sms->lastCodeFor(self::PHONE),
            'password' => 'new-pass1',
            'password_confirmation' => 'new-pass1',
            'device_name' => 'pixel-8',
        ])->assertOk()->assertJsonStructure(['data' => ['token', 'user']]);

        $this->assertSame(1, $user->tokens()->count()); // the old phone was signed out
        $this->login(self::PHONE, 'old-pass1')->assertUnprocessable();
        $this->login(self::PHONE, 'new-pass1')->assertOk();
    }

    public function test_forgot_password_does_not_reveal_which_numbers_exist(): void
    {
        $this->postJson('/api/v1/auth/password/forgot', ['phone' => self::PHONE])
            ->assertOk()
            ->assertJsonPath('message', 'إذا كان الرقم مسجلًا لدينا فسيصلك رمز تحقق برسالة نصية خلال لحظات.');

        $this->assertSame([], $this->sms->sent);

        $this->postJson('/api/v1/auth/password/reset', [
            'phone' => self::PHONE,
            'code' => '123456',
            'password' => 'new-pass1',
            'password_confirmation' => 'new-pass1',
            'device_name' => 'x',
        ])->assertUnprocessable()->assertJsonPath('errors.code.0', 'رمز التحقق غير صحيح أو منتهي الصلاحية.');
    }

    public function test_customer_changes_password_and_other_devices_are_signed_out(): void
    {
        $user = User::factory()->create(['phone' => self::PHONE, 'password' => 'old-pass1']);
        $user->createToken('tablet');
        $token = $this->login(self::PHONE, 'old-pass1')->json('data.token');

        $this->withToken($token)
            ->postJson('/api/v1/auth/password/change', [
                'current_password' => 'wrong-1',
                'password' => 'new-pass1',
                'password_confirmation' => 'new-pass1',
            ])
            ->assertUnprocessable()
            ->assertJsonPath('errors.current_password.0', 'كلمة المرور الحالية غير صحيحة.');

        $this->withToken($token)
            ->postJson('/api/v1/auth/password/change', [
                'current_password' => 'old-pass1',
                'password' => 'new-pass1',
                'password_confirmation' => 'new-pass1',
            ])
            ->assertOk()
            ->assertJsonPath('message', 'تم تغيير كلمة المرور.');

        $this->assertSame(1, $user->tokens()->count());
        $this->withToken($token)->getJson('/api/v1/auth/me')->assertOk();
        $this->login(self::PHONE, 'new-pass1')->assertOk();
    }

    // ------------------------------------------------------------------ Profile and session

    public function test_national_number_and_documents_complete_the_profile(): void
    {
        Storage::fake('local');
        $user = User::factory()->create(['national_id' => null]);

        $this->actingAsUser($user)
            ->patchJson('/api/v1/me', ['national_id' => '29501011234567'])
            ->assertUnprocessable()
            ->assertJsonPath('errors.national_id.0', 'الرقم الوطني غير صحيح، يجب أن يتكون من 12 رقماً ويبدأ بـ 1 أو 2.');

        $this->patchJson('/api/v1/me', ['national_id' => '١١٩٩٥٠١٢٣٤٥٦', 'address' => 'طرابلس'])
            ->assertOk()
            ->assertJsonPath('data.national_id', '119950123456')
            ->assertJsonPath('data.address', 'طرابلس')
            ->assertJsonPath('data.kyc_completed', false);

        $response = $this->post('/api/v1/me/documents', [
            'id_image' => UploadedFile::fake()->image('id.jpg', 800, 500),
            'license_image' => UploadedFile::fake()->image('license.png', 800, 500),
        ])->assertOk()->assertJsonPath('data.kyc_completed', true);

        $user->refresh();
        Storage::disk('local')->assertExists([$user->id_image, $user->license_image]);

        // Documents are private: only short-lived signed links work.
        $signedUrl = $response->json('data.documents.id_image.url');
        $this->get($signedUrl)->assertOk();
        $this->getJson(strtok($signedUrl, '?'))->assertForbidden();
        $this->getJson($signedUrl.'x')->assertForbidden()->assertJsonPath('message', 'الرابط غير صالح أو منتهي الصلاحية.');
    }

    public function test_upload_rejects_non_image_files(): void
    {
        $this->actingAsUser($this->customer())
            ->post('/api/v1/me/documents', ['id_image' => UploadedFile::fake()->create('id.pdf', 100, 'application/pdf')])
            ->assertUnprocessable()
            ->assertJsonValidationErrors('id_image');
    }

    public function test_logout_revokes_the_current_token(): void
    {
        User::factory()->create(['phone' => self::PHONE, 'password' => 'secret12']);
        $token = $this->login(self::PHONE, 'secret12')->json('data.token');

        $this->withToken($token)->postJson('/api/v1/auth/logout')->assertOk();

        $this->assertDatabaseCount('personal_access_tokens', 0);
    }

    public function test_protected_routes_return_json_401_in_arabic(): void
    {
        $this->get('/api/v1/auth/me')
            ->assertUnauthorized()
            ->assertExactJson(['success' => false, 'message' => 'يجب تسجيل الدخول أولاً.']);
    }
}
