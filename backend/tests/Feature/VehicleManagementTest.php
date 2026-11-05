<?php

namespace Tests\Feature;

use App\Enums\UserRole;
use App\Models\Policy;
use App\Models\User;
use App\Models\Vehicle;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class VehicleManagementTest extends TestCase
{
    use RefreshDatabase;

    private function payload(array $overrides = []): array
    {
        return [
            'plate_no' => ' ٥ - ١٢٣٤٥٦ ',
            'vin' => 'jtdbr32e720123456',
            'make' => 'Toyota',
            'model' => 'Corolla',
            'year' => 2019,
            'engine_cc' => 1600,
            ...$overrides,
        ];
    }

    public function test_customer_registers_a_vehicle_with_normalized_plate_and_vin(): void
    {
        $user = $this->customer();

        $this->actingAsUser($user)
            ->postJson('/api/v1/vehicles', $this->payload())
            ->assertCreated()
            ->assertJsonPath('data.plate_no', '5-123456')
            ->assertJsonPath('data.vin', 'JTDBR32E720123456')
            ->assertJsonPath('message', 'تمت إضافة المركبة بنجاح.');

        $this->assertDatabaseHas('vehicles', ['user_id' => $user->id, 'vin' => 'JTDBR32E720123456']);
    }

    public function test_vin_must_be_unique_and_valid(): void
    {
        Vehicle::factory()->create(['vin' => 'JTDBR32E720123456']);

        $this->actingAsUser($this->customer())
            ->postJson('/api/v1/vehicles', $this->payload())
            ->assertUnprocessable()
            ->assertJsonPath('errors.vin.0', 'رقم الشاسيه مسجل لمركبة أخرى.');

        $this->postJson('/api/v1/vehicles', $this->payload(['vin' => 'IOQ123']))
            ->assertUnprocessable()
            ->assertJsonValidationErrors('vin');
    }

    public function test_validation_messages_use_arabic_attribute_names(): void
    {
        $this->actingAsUser($this->customer())
            ->postJson('/api/v1/vehicles', [])
            ->assertUnprocessable()
            ->assertJsonPath('errors.plate_no.0', 'حقل رقم اللوحة مطلوب.')
            ->assertJsonPath('errors.engine_cc.0', 'حقل سعة المحرك مطلوب.');
    }

    public function test_customer_lists_only_own_vehicles(): void
    {
        $user = $this->customer();
        Vehicle::factory()->count(2)->for($user)->create();
        Vehicle::factory()->count(3)->create();

        $this->actingAsUser($user)
            ->getJson('/api/v1/vehicles')
            ->assertOk()
            ->assertJsonCount(2, 'data')
            ->assertJsonPath('meta.pagination.total', 2);
    }

    public function test_customer_cannot_access_another_customers_vehicle(): void
    {
        $vehicle = Vehicle::factory()->create();
        $this->actingAsUser($this->customer());

        $this->getJson("/api/v1/vehicles/{$vehicle->id}")
            ->assertForbidden()
            ->assertJsonPath('message', 'هذه المركبة غير مسجلة باسمك.');
        $this->patchJson("/api/v1/vehicles/{$vehicle->id}", ['make' => 'Kia'])->assertForbidden();
        $this->deleteJson("/api/v1/vehicles/{$vehicle->id}")->assertForbidden();
    }

    public function test_customer_updates_own_vehicle(): void
    {
        $user = $this->customer();
        $vehicle = Vehicle::factory()->for($user)->create();

        $this->actingAsUser($user)
            ->patchJson("/api/v1/vehicles/{$vehicle->id}", ['engine_cc' => 2000, 'vin' => $vehicle->vin])
            ->assertOk()
            ->assertJsonPath('data.engine_cc', 2000);
    }

    public function test_vehicle_with_active_policy_cannot_be_modified_or_deleted(): void
    {
        $user = $this->customer();
        $vehicle = Vehicle::factory()->for($user)->create();
        Policy::factory()->active()->for($vehicle)->create();

        $this->actingAsUser($user)
            ->patchJson("/api/v1/vehicles/{$vehicle->id}", ['engine_cc' => 1000])
            ->assertUnprocessable()
            ->assertJsonPath('message', 'لا يمكن تعديل بيانات مركبة لديها وثيقة سارية أو بانتظار الدفع.');

        $this->deleteJson("/api/v1/vehicles/{$vehicle->id}")
            ->assertUnprocessable()
            ->assertJsonPath('message', 'لا يمكن حذف مركبة لها وثائق تأمين مسجلة.');
    }

    public function test_customer_deletes_vehicle_without_policies(): void
    {
        $user = $this->customer();
        $vehicle = Vehicle::factory()->for($user)->create();

        $this->actingAsUser($user)->deleteJson("/api/v1/vehicles/{$vehicle->id}")->assertOk();

        $this->assertModelMissing($vehicle);
    }

    public function test_non_customer_roles_cannot_use_customer_endpoints(): void
    {
        $this->actingAsUser(User::factory()->role(UserRole::Surveyor)->create())
            ->getJson('/api/v1/vehicles')
            ->assertForbidden()
            ->assertJsonPath('message', 'ليس لديك صلاحية لتنفيذ هذا الإجراء.');
    }

    public function test_unknown_vehicle_returns_json_404(): void
    {
        $this->actingAsUser($this->customer())
            ->getJson('/api/v1/vehicles/999')
            ->assertNotFound()
            ->assertJsonPath('message', 'العنصر المطلوب غير موجود.');
    }
}
