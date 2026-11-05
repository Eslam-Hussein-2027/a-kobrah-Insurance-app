<?php

namespace Tests\Feature\Admin;

use App\Enums\UserRole;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Testing\TestResponse;
use Tests\TestCase;

class StaffLoginTest extends TestCase
{
    use RefreshDatabase;

    private function login(string $phone, string $password): TestResponse
    {
        return $this->postJson('/api/v1/auth/staff/login', [
            'phone' => $phone,
            'password' => $password,
            'device_name' => 'dashboard',
        ]);
    }

    public function test_admin_logs_in_with_phone_and_password(): void
    {
        User::factory()->role(UserRole::Admin)->create(['phone' => '0910000001', 'password' => 'secret-123']);

        $token = $this->login('+218 91 000 0001', 'secret-123')
            ->assertOk()
            ->assertJsonPath('data.user.role.value', 'admin')
            ->json('data.token');

        $this->withToken($token)->getJson('/api/v1/admin/stats')->assertOk();
    }

    public function test_wrong_password_is_rejected_with_a_generic_message(): void
    {
        User::factory()->role(UserRole::Admin)->create(['phone' => '0910000001', 'password' => 'secret-123']);

        $this->login('0910000001', 'wrong')
            ->assertUnprocessable()
            ->assertJsonPath('errors.phone.0', 'رقم الهاتف أو كلمة المرور غير صحيحة.');

        $this->login('0919999999', 'secret-123')
            ->assertUnprocessable()
            ->assertJsonPath('errors.phone.0', 'رقم الهاتف أو كلمة المرور غير صحيحة.');
    }

    public function test_customers_cannot_use_password_login(): void
    {
        User::factory()->create(['phone' => '0911234567', 'password' => 'secret-123']);

        $this->login('0911234567', 'secret-123')->assertUnprocessable();
    }

    public function test_disabled_staff_cannot_log_in(): void
    {
        User::factory()->role(UserRole::Admin)->inactive()->create(['phone' => '0910000001', 'password' => 'secret-123']);

        $this->login('0910000001', 'secret-123')->assertUnprocessable();
    }

    public function test_customers_cannot_reach_admin_endpoints(): void
    {
        $this->actingAsUser($this->customer());

        $this->getJson('/api/v1/admin/stats')->assertForbidden();
        $this->getJson('/api/v1/admin/policies')->assertForbidden();
        $this->getJson('/api/v1/admin/pricing')->assertForbidden();
    }
}
