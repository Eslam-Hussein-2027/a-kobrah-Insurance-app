<?php

namespace Tests\Feature\Admin;

use App\Models\Policy;
use App\Models\Vehicle;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AdminCustomersTest extends TestCase
{
    use RefreshDatabase;

    public function test_admin_lists_and_searches_customers_with_counts(): void
    {
        $admin = $this->admin();
        $customer = $this->customer(['name' => 'خديجة المصراتي', 'phone' => '0947778888']);
        Policy::factory()->for(Vehicle::factory()->for($customer))->create();
        $this->customer();

        $this->actingAsUser($admin)->getJson('/api/v1/admin/customers')
            ->assertOk()
            ->assertJsonCount(2, 'data'); // the admin is not listed

        $this->getJson('/api/v1/admin/customers?search=المصراتي')
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.vehicles_count', 1)
            ->assertJsonPath('data.0.policies_count', 1)
            ->assertJsonPath('data.0.kyc_completed', true);
    }

    public function test_customer_details_include_vehicles_policies_and_document_links(): void
    {
        $customer = $this->customer();
        Policy::factory()->for(Vehicle::factory()->for($customer))->create();

        $this->actingAsUser($this->admin())
            ->getJson("/api/v1/admin/customers/{$customer->id}")
            ->assertOk()
            ->assertJsonCount(1, 'data.vehicles')
            ->assertJsonCount(1, 'data.policies')
            ->assertJsonPath('data.documents.id_image.uploaded', true)
            ->assertJsonPath('data.documents.id_image.label', 'صورة إثبات الهوية (البطاقة الشخصية أو جواز السفر)');
    }

    public function test_blocking_a_customer_revokes_access(): void
    {
        $customer = $this->customer(['phone' => '0911112222']);
        $token = $customer->createToken('phone')->plainTextToken;

        $this->actingAsUser($this->admin())
            ->patchJson("/api/v1/admin/customers/{$customer->id}", ['is_active' => false])
            ->assertOk()
            ->assertJsonPath('data.is_active', false)
            ->assertJsonPath('message', 'تم إيقاف حساب العميل.');

        $this->assertDatabaseCount('personal_access_tokens', 0);
        $this->app['auth']->forgetGuards();
        $this->withToken($token)->getJson('/api/v1/auth/me')->assertUnauthorized();
    }

    public function test_staff_accounts_are_not_exposed_as_customers(): void
    {
        $admin = $this->admin();

        $this->actingAsUser($admin)->getJson("/api/v1/admin/customers/{$admin->id}")->assertNotFound();
    }
}
