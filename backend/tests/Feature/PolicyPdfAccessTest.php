<?php

namespace Tests\Feature;

use App\Jobs\GeneratePolicyPdf;
use App\Models\CoverageType;
use App\Models\Policy;
use App\Models\User;
use App\Models\Vehicle;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

/**
 * Rule: only the policy owner can download the PDF, and only while status = ACTIVE.
 */
class PolicyPdfAccessTest extends TestCase
{
    use RefreshDatabase;

    private User $owner;

    protected function setUp(): void
    {
        parent::setUp();

        Storage::fake('local');
        $this->seedPricing();
        $this->owner = $this->customer(['name' => 'محمد أحمد علي']);
    }

    private function policy(string $state = 'active'): Policy
    {
        $vehicle = Vehicle::factory()->for($this->owner)->create(['plate_no' => '5-123456']);
        $factory = Policy::factory()->for($vehicle)->for(CoverageType::query()->where('code', CoverageType::COMPREHENSIVE)->firstOrFail());

        return match ($state) {
            'active' => $factory->active()->create(),
            'expired' => $factory->expired()->create(),
            'cancelled' => $factory->cancelled()->create(),
            default => $factory->create(),
        };
    }

    public function test_owner_downloads_active_policy_as_pdf(): void
    {
        $policy = $this->policy();

        $response = $this->actingAsUser($this->owner)->get("/api/v1/policies/{$policy->id}/pdf");

        $response->assertOk()
            ->assertHeader('Content-Type', 'application/pdf')
            ->assertDownload($policy->policy_no.'.pdf');

        $this->assertStringStartsWith('%PDF-', $response->streamedContent());

        $policy->refresh();
        $this->assertSame("policies/{$policy->issued_at->format('Y')}/{$policy->policy_no}.pdf", $policy->pdf_path);
        Storage::disk('local')->assertExists($policy->pdf_path);
    }

    public function test_pending_payment_policy_cannot_be_downloaded(): void
    {
        $policy = $this->policy('pending');

        $this->actingAsUser($this->owner)
            ->getJson("/api/v1/policies/{$policy->id}/pdf")
            ->assertForbidden()
            ->assertJsonPath('message', 'لا يمكن تحميل الوثيقة إلا بعد تفعيلها.');
    }

    public function test_expired_and_cancelled_policies_cannot_be_downloaded(): void
    {
        $this->actingAsUser($this->owner);

        $this->getJson('/api/v1/policies/'.$this->policy('expired')->id.'/pdf')->assertForbidden();
        $this->getJson('/api/v1/policies/'.$this->policy('cancelled')->id.'/pdf')->assertForbidden();
    }

    public function test_another_customer_cannot_download_the_policy(): void
    {
        $policy = $this->policy();

        $this->actingAsUser($this->customer())
            ->getJson("/api/v1/policies/{$policy->id}/pdf")
            ->assertForbidden()
            ->assertJsonPath('message', 'هذه الوثيقة غير مسجلة باسمك.');
    }

    public function test_admin_cannot_download_through_the_customer_endpoint(): void
    {
        $policy = $this->policy();

        $this->actingAsUser($this->admin())
            ->getJson("/api/v1/policies/{$policy->id}/pdf")
            ->assertForbidden();
    }

    public function test_guest_cannot_download(): void
    {
        $policy = $this->policy();

        $this->getJson("/api/v1/policies/{$policy->id}/pdf")->assertUnauthorized();
    }

    public function test_stored_pdf_is_reused_instead_of_regenerated(): void
    {
        $policy = $this->policy();
        $this->actingAsUser($this->owner)->get("/api/v1/policies/{$policy->id}/pdf")->assertOk();

        $path = $policy->refresh()->pdf_path;
        Storage::disk('local')->put($path, '%PDF-cached-copy');

        $this->assertSame(
            '%PDF-cached-copy',
            $this->get("/api/v1/policies/{$policy->id}/pdf")->assertOk()->streamedContent(),
        );
    }

    public function test_queued_job_generates_the_pdf_for_active_policies_only(): void
    {
        $active = $this->policy();
        $pending = $this->policy('pending');

        GeneratePolicyPdf::dispatchSync($active->id);
        GeneratePolicyPdf::dispatchSync($pending->id);

        Storage::disk('local')->assertExists($active->refresh()->pdf_path);
        $this->assertNull($pending->refresh()->pdf_path);
    }
}
