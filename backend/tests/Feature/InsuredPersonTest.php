<?php

namespace Tests\Feature;

use App\Enums\InsuranceProduct;
use App\Models\InsuredPerson;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class InsuredPersonTest extends TestCase
{
    use RefreshDatabase;

    private User $customer;

    protected function setUp(): void
    {
        parent::setUp();

        // These tests exercise switched-off products too.
        config(['products.offered' => array_column(InsuranceProduct::cases(), 'value')]);

        $this->customer = $this->customer();
    }

    public function test_customer_adds_a_person_with_normalized_documents(): void
    {
        $this->actingAsUser($this->customer)
            ->postJson('/api/v1/persons', [
                'full_name' => '  سارة   محمد  ',
                'relationship' => 'spouse',
                'birth_date' => '1991-09-03',
                'passport_no' => 'ly 90 21 ab',
                'national_id' => '٢١٩٩١٠٠٠٠٠٠١',
            ])
            ->assertCreated()
            ->assertJsonPath('data.full_name', 'سارة محمد')
            ->assertJsonPath('data.relationship.value', 'spouse')
            ->assertJsonPath('data.relationship.label', 'الزوج / الزوجة')
            ->assertJsonPath('data.passport_no', 'LY9021AB')
            ->assertJsonPath('data.national_id', '219910000001');

        $this->assertDatabaseHas('insured_persons', ['user_id' => $this->customer->id, 'full_name' => 'سارة محمد']);
    }

    public function test_customer_lists_only_their_own_persons(): void
    {
        InsuredPerson::factory()->count(2)->for($this->customer)->create();
        InsuredPerson::factory()->create();

        $this->actingAsUser($this->customer)
            ->getJson('/api/v1/persons')
            ->assertOk()
            ->assertJsonCount(2, 'data');
    }

    public function test_customer_updates_and_deletes_a_person(): void
    {
        $person = InsuredPerson::factory()->for($this->customer)->create();

        $this->actingAsUser($this->customer)
            ->putJson("/api/v1/persons/{$person->id}", [
                'full_name' => 'يوسف أحمد',
                'relationship' => 'child',
                'birth_date' => '2016-02-21',
            ])
            ->assertOk()
            ->assertJsonPath('data.full_name', 'يوسف أحمد')
            ->assertJsonPath('data.passport_no', null);

        $this->deleteJson("/api/v1/persons/{$person->id}")->assertOk();
        $this->assertModelMissing($person);
    }

    public function test_other_customers_persons_are_not_accessible(): void
    {
        $someoneElse = InsuredPerson::factory()->create();

        $this->actingAsUser($this->customer)
            ->getJson("/api/v1/persons/{$someoneElse->id}")
            ->assertForbidden();

        $this->deleteJson("/api/v1/persons/{$someoneElse->id}")->assertForbidden();
        $this->assertModelExists($someoneElse);
    }

    public function test_validation(): void
    {
        $this->actingAsUser($this->customer)
            ->postJson('/api/v1/persons', [
                'full_name' => 'س',
                'relationship' => 'cousin',
                'birth_date' => now()->addDay()->toDateString(),
                'passport_no' => '12',
            ])
            ->assertUnprocessable()
            ->assertJsonValidationErrors(['full_name', 'relationship', 'birth_date', 'passport_no']);
    }
}
