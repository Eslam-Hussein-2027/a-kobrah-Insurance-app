<?php

namespace Tests\Feature;

use App\Models\Policy;
use App\Models\Vehicle;
use Carbon\CarbonImmutable;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Testing\TestResponse;
use Tests\TestCase;

class PolicyVerificationTest extends TestCase
{
    use RefreshDatabase;

    private Vehicle $vehicle;

    protected function setUp(): void
    {
        parent::setUp();

        $this->travelTo(CarbonImmutable::parse('2026-06-01 10:00:00'));
        $this->vehicle = Vehicle::factory()->create(['plate_no' => '5-123456']);
    }

    private function verify(string $policyNo, string $plateNo): TestResponse
    {
        return $this->getJson('/api/v1/policies/verify?'.http_build_query([
            'policy_no' => $policyNo,
            'plate_no' => $plateNo,
        ]));
    }

    public function test_active_policy_is_valid_and_exposes_no_personal_data(): void
    {
        $policy = Policy::factory()->active()->for($this->vehicle)->create(['policy_no' => 'POL-2026-000123']);

        $this->verify('pol-2026-000123', '٥ ١٢٣٤٥٦') // case, dash/spacing and Arabic digits are normalized
            ->assertOk()
            ->assertJsonPath('data.result.value', 'VALID')
            ->assertJsonPath('message', 'الوثيقة سارية')
            ->assertJsonPath('data.policy_no', $policy->policy_no)
            ->assertJsonPath('data.end_date', $policy->end_date->toDateString())
            ->assertJsonMissingPath('data.customer')
            ->assertJsonMissingPath('data.national_id')
            ->assertJsonMissingPath('data.vin');
    }

    public function test_expired_policies_are_reported_as_expired(): void
    {
        Policy::factory()->expired()->for($this->vehicle)->create(['policy_no' => 'POL-2025-000001']);
        // Still ACTIVE in DB but past its end date (expiry job not run yet).
        Policy::factory()->active()->for($this->vehicle)->create([
            'policy_no' => 'POL-2025-000002',
            'start_date' => '2025-05-01',
            'end_date' => '2026-04-30',
        ]);

        $this->verify('POL-2025-000001', '5-123456')->assertJsonPath('data.result.value', 'EXPIRED');
        $this->verify('POL-2025-000002', '5-123456')->assertJsonPath('data.result.value', 'EXPIRED');
    }

    public function test_wrong_plate_unknown_number_or_unpaid_policy_is_not_found(): void
    {
        Policy::factory()->active()->for($this->vehicle)->create(['policy_no' => 'POL-2026-000001']);
        Policy::factory()->for($this->vehicle)->create(['policy_no' => 'POL-2026-000002']); // pending payment

        foreach ([
            ['POL-2026-000001', '5-999999'],
            ['POL-2026-999999', '5-123456'],
            ['POL-2026-000002', '5-123456'],
        ] as [$policyNo, $plateNo]) {
            $this->verify($policyNo, $plateNo)
                ->assertOk()
                ->assertJsonPath('data.result.value', 'NOT_FOUND')
                ->assertJsonMissingPath('data.policy_no');
        }
    }

    public function test_both_fields_are_required(): void
    {
        $this->getJson('/api/v1/policies/verify?policy_no=POL-2026-000001')
            ->assertUnprocessable()
            ->assertJsonValidationErrors('plate_no');

        $this->getJson('/api/v1/policies/verify?plate_no=1234')
            ->assertUnprocessable()
            ->assertJsonValidationErrors('policy_no');
    }

    public function test_endpoint_is_rate_limited(): void
    {
        foreach (range(1, 10) as $_) {
            $this->verify('POL-2026-000001', '1234')->assertOk();
        }

        $this->verify('POL-2026-000001', '1234')->assertTooManyRequests();
    }
}
