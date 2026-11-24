<?php

namespace Tests\Feature;

use App\Enums\InsuranceRequestStatus;
use App\Models\InsuranceRequest;
use App\Models\User;
use App\Models\Vehicle;
use Carbon\CarbonImmutable;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

class InsuranceRequestTest extends TestCase
{
    use RefreshDatabase;

    private User $customer;

    protected function setUp(): void
    {
        parent::setUp();

        $this->travelTo(CarbonImmutable::parse('2026-11-24 10:00:00'));
        Storage::fake((string) config('insurance.uploads.disk'));
        $this->customer = $this->customer();
    }

    public function test_customer_requests_a_marine_quote_with_documents(): void
    {
        $this->actingAsUser($this->customer)
            ->post('/api/v1/requests', [
                'product' => 'marine_cargo',
                'kind' => 'quote',
                'answers' => [
                    'cargo_type' => 'مواد غذائية',
                    'origin_port' => 'ميناء الإسكندرية',
                    'destination_port' => 'ميناء بنغازي',
                    'cargo_value' => '٢٥٠٠٠٠',
                    'unknown_field' => 'ignored',
                ],
                'notes' => 'شحنة مبردة',
                'documents' => [
                    'commercial_invoice' => UploadedFile::fake()->create('invoice.pdf', 120, 'application/pdf'),
                    'not_a_document_key' => UploadedFile::fake()->image('x.jpg'),
                ],
            ], ['Accept' => 'application/json'])
            ->assertCreated()
            ->assertJsonPath('data.request_no', 'REQ-2026-000001')
            ->assertJsonPath('data.product.value', 'marine_cargo')
            ->assertJsonPath('data.product.label', 'التأمين البحري')
            ->assertJsonPath('data.kind.value', 'quote')
            ->assertJsonPath('data.status.value', 'SUBMITTED')
            ->assertJsonPath('data.can_cancel', true)
            ->assertJsonPath('data.details.0.label', 'نوع البضاعة')
            ->assertJsonPath('data.details.3.key', 'cargo_value')
            ->assertJsonPath('data.details.3.value', '250000')
            ->assertJsonCount(4, 'data.details')
            ->assertJsonCount(1, 'data.documents')
            ->assertJsonPath('data.documents.0.label', 'الفاتورة التجارية')
            ->assertJsonMissingPath('data.documents.0.url');

        $request = InsuranceRequest::query()->sole();
        Storage::disk((string) config('insurance.uploads.disk'))->assertExists($request->documents()->sole()->path);
    }

    public function test_vehicle_answers_are_stored_as_a_readable_snapshot(): void
    {
        $vehicle = Vehicle::factory()->for($this->customer)->create([
            'make' => 'Toyota', 'model' => 'Hilux', 'year' => 2019, 'plate_no' => '7-334519',
        ]);

        $this->actingAsUser($this->customer)
            ->postJson('/api/v1/requests', [
                'product' => 'orange_card',
                'kind' => 'issue',
                'answers' => [
                    'vehicle' => $vehicle->id,
                    'destination_country' => 'تونس',
                    'travel_date' => '2026-12-10',
                    'duration_days' => 30,
                ],
            ])
            ->assertCreated()
            ->assertJsonPath('data.details.0.value', 'Toyota Hilux 2019 · 7-334519');
    }

    public function test_another_customers_vehicle_cannot_be_used(): void
    {
        $this->actingAsUser($this->customer)
            ->postJson('/api/v1/requests', [
                'product' => 'orange_card',
                'kind' => 'issue',
                'answers' => [
                    'vehicle' => Vehicle::factory()->create()->id,
                    'destination_country' => 'تونس',
                    'travel_date' => '2026-12-10',
                    'duration_days' => 30,
                ],
            ])
            ->assertUnprocessable()
            ->assertJsonValidationErrors(['answers.vehicle']);
    }

    public function test_required_fields_follow_the_product_definition(): void
    {
        $errors = $this->actingAsUser($this->customer)
            ->postJson('/api/v1/requests', [
                'product' => 'foreign_workers',
                'kind' => 'issue',
                'answers' => ['workers_count' => 0],
            ])
            ->assertUnprocessable()
            ->assertJsonValidationErrors(['answers.workers_count', 'answers.nationality', 'answers.employer_name'])
            ->json('errors');

        // Field names come from the product catalog, not the raw keys.
        $this->assertStringContainsString('الجنسية', $errors['answers.nationality'][0]);
    }

    public function test_instant_products_cannot_be_requested(): void
    {
        $this->actingAsUser($this->customer)
            ->postJson('/api/v1/requests', ['product' => 'motor', 'kind' => 'issue'])
            ->assertUnprocessable()
            ->assertJsonValidationErrors(['product']);
    }

    public function test_customer_lists_views_and_cancels_their_requests(): void
    {
        $mine = InsuranceRequest::factory()->for($this->customer)->create();
        InsuranceRequest::factory()->create();

        $this->actingAsUser($this->customer)
            ->getJson('/api/v1/requests')
            ->assertOk()
            ->assertJsonCount(1, 'data');

        $this->postJson("/api/v1/requests/{$mine->id}/cancel")
            ->assertOk()
            ->assertJsonPath('data.status.value', 'CANCELLED')
            ->assertJsonPath('data.can_cancel', false);

        $this->postJson("/api/v1/requests/{$mine->id}/cancel")->assertUnprocessable();
    }

    public function test_other_customers_requests_are_private(): void
    {
        $other = InsuranceRequest::factory()->status(InsuranceRequestStatus::InReview)->create();

        $this->actingAsUser($this->customer)->getJson("/api/v1/requests/{$other->id}")->assertForbidden();
        $this->postJson("/api/v1/requests/{$other->id}/cancel")->assertForbidden();
    }
}
