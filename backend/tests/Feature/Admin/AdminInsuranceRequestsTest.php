<?php

namespace Tests\Feature\Admin;

use App\Enums\InsuranceProduct;
use App\Enums\InsuranceRequestStatus;
use App\Models\InsuranceRequest;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

class AdminInsuranceRequestsTest extends TestCase
{
    use RefreshDatabase;

    private User $admin;

    protected function setUp(): void
    {
        parent::setUp();

        $this->admin = $this->admin();
    }

    public function test_admin_lists_and_filters_requests(): void
    {
        $customer = $this->customer(['name' => 'خديجة المصراتي']);
        InsuranceRequest::factory()->for($customer)->create(['request_no' => 'REQ-2026-000007']);
        InsuranceRequest::factory()->create(['product' => InsuranceProduct::ForeignWorkers, 'details' => ['workers_count' => 3]]);
        InsuranceRequest::factory()->status(InsuranceRequestStatus::Completed)->create();

        $this->actingAsUser($this->admin)->getJson('/api/v1/admin/requests')
            ->assertOk()
            ->assertJsonCount(3, 'data');

        $this->getJson('/api/v1/admin/requests?status=SUBMITTED')->assertJsonCount(2, 'data');
        $this->getJson('/api/v1/admin/requests?product=foreign_workers')->assertJsonCount(1, 'data');
        $this->getJson('/api/v1/admin/requests?search=المصراتي')
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.request_no', 'REQ-2026-000007')
            ->assertJsonPath('data.0.customer.name', 'خديجة المصراتي');
    }

    public function test_admin_sees_signed_document_links(): void
    {
        Storage::fake((string) config('insurance.uploads.disk'));
        Storage::disk((string) config('insurance.uploads.disk'))->put('requests/1/invoice.pdf', 'pdf');

        $request = InsuranceRequest::factory()->create();
        $request->documents()->create([
            'document_key' => 'commercial_invoice',
            'path' => 'requests/1/invoice.pdf',
            'original_name' => 'invoice.pdf',
            'mime_type' => 'application/pdf',
            'size' => 3,
        ]);

        $url = $this->actingAsUser($this->admin)
            ->getJson("/api/v1/admin/requests/{$request->id}")
            ->assertOk()
            ->json('data.documents.0.url');

        $this->assertStringContainsString('signature=', $url);
        $this->get($url)->assertOk();
        $this->get(strtok($url, '?'))->assertForbidden();
    }

    public function test_quote_reply_requires_an_amount(): void
    {
        $request = InsuranceRequest::factory()->create();

        $this->actingAsUser($this->admin)
            ->postJson("/api/v1/admin/requests/{$request->id}/respond", ['status' => 'QUOTED'])
            ->assertUnprocessable()
            ->assertJsonValidationErrors(['quoted_amount']);

        $this->postJson("/api/v1/admin/requests/{$request->id}/respond", [
            'status' => 'QUOTED',
            'quoted_amount' => '١٨٥٠',
            'reply' => 'السعر شامل الضريبة.',
        ])
            ->assertOk()
            ->assertJsonPath('data.status.value', 'QUOTED')
            ->assertJsonPath('data.quoted_amount', '1850.00')
            ->assertJsonPath('data.staff_reply', 'السعر شامل الضريبة.');

        $this->assertDatabaseHas('insurance_requests', ['id' => $request->id, 'handled_by' => $this->admin->id]);
    }

    public function test_rejection_requires_a_reason_and_closes_the_request(): void
    {
        $request = InsuranceRequest::factory()->create();

        $this->actingAsUser($this->admin)
            ->postJson("/api/v1/admin/requests/{$request->id}/respond", ['status' => 'REJECTED'])
            ->assertJsonValidationErrors(['reply']);

        $this->postJson("/api/v1/admin/requests/{$request->id}/respond", ['status' => 'REJECTED', 'reply' => 'البيانات غير مكتملة.'])
            ->assertOk();

        $this->postJson("/api/v1/admin/requests/{$request->id}/respond", ['status' => 'IN_REVIEW'])
            ->assertUnprocessable()
            ->assertJsonPath('message', 'هذا الطلب مغلق ولا يمكن تعديله.');
    }

    public function test_customers_cannot_use_admin_endpoints(): void
    {
        $request = InsuranceRequest::factory()->create();

        $this->actingAsUser($this->customer())
            ->postJson("/api/v1/admin/requests/{$request->id}/respond", ['status' => 'COMPLETED'])
            ->assertForbidden();
    }
}
