<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class CatalogTest extends TestCase
{
    use RefreshDatabase;

    public function test_only_offered_products_are_listed_in_order_with_issuance_mode(): void
    {
        $this->getJson('/api/v1/products')
            ->assertOk()
            ->assertJsonCount(2, 'data')
            ->assertJsonPath('data.0.code', 'motor')
            ->assertJsonPath('data.0.name', 'التأمين الإجباري')
            ->assertJsonPath('data.0.issuance', 'instant')
            ->assertJsonPath('data.0.fields', [])
            ->assertJsonPath('data.1.code', 'marine_cargo')
            ->assertJsonPath('data.1.issuance', 'request')
            ->assertJsonPath('data.1.fields.0.key', 'cargo_type')
            ->assertJsonPath('data.1.fields.0.label', 'نوع البضاعة')
            ->assertJsonPath('data.1.fields.0.required', true)
            ->assertJsonPath('data.1.documents.1.key', 'bill_of_lading');
    }

    public function test_switched_off_products_are_refused(): void
    {
        $customer = $this->customer();

        $this->actingAsUser($customer)->getJson('/api/v1/travel/options')->assertNotFound();
        $this->getJson('/api/v1/persons')->assertNotFound();
        $this->postJson('/api/v1/requests', ['product' => 'orange_card', 'kind' => 'quote'])
            ->assertUnprocessable()
            ->assertJsonValidationErrors('product');

        $this->actingAsUser($this->admin())
            ->getJson('/api/v1/admin/pricing')
            ->assertOk()
            ->assertJsonMissingPath('data.travel_rates');
    }

    public function test_a_product_comes_back_when_it_is_offered_again(): void
    {
        config(['products.offered' => ['motor', 'travel', 'marine_cargo']]);

        $this->getJson('/api/v1/products')->assertJsonPath('data.1.code', 'travel');
        $this->actingAsUser($this->customer())->getJson('/api/v1/travel/options')->assertOk();
    }

    public function test_products_follow_the_app_language(): void
    {
        config(['products.offered' => ['motor', 'travel', 'orange_card']]);

        $this->withHeader('Accept-Language', 'en')
            ->getJson('/api/v1/products')
            ->assertJsonPath('data.2.name', 'Orange Card')
            ->assertJsonPath('data.2.fields.1.label', 'Destination country');
    }

    public function test_company_information_includes_branches_and_texts(): void
    {
        $this->getJson('/api/v1/company')
            ->assertOk()
            ->assertJsonPath('data.name', 'العربية الكبرى للتأمين المساهمة')
            ->assertJsonPath('data.phone', '0925441206')
            ->assertJsonPath('data.branches.0.city', 'بنغازي')
            ->assertJsonPath('data.branches.0.is_head_office', true)
            ->assertJsonStructure(['data' => ['about', 'privacy', 'website']]);
    }
}
