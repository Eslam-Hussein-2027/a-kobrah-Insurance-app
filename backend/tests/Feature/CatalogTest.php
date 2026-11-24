<?php

namespace Tests\Feature;

use Tests\TestCase;

class CatalogTest extends TestCase
{
    public function test_products_are_listed_in_order_with_issuance_mode(): void
    {
        $this->getJson('/api/v1/products')
            ->assertOk()
            ->assertJsonCount(6, 'data')
            ->assertJsonPath('data.0.code', 'motor')
            ->assertJsonPath('data.0.name', 'التأمين الإجباري')
            ->assertJsonPath('data.0.issuance', 'instant')
            ->assertJsonPath('data.0.fields', [])
            ->assertJsonPath('data.1.code', 'travel')
            ->assertJsonPath('data.1.issuance', 'instant')
            ->assertJsonPath('data.5.code', 'marine_cargo')
            ->assertJsonPath('data.5.issuance', 'request')
            ->assertJsonPath('data.5.fields.0.key', 'cargo_type')
            ->assertJsonPath('data.5.fields.0.label', 'نوع البضاعة')
            ->assertJsonPath('data.5.fields.0.required', true)
            ->assertJsonPath('data.5.documents.1.key', 'bill_of_lading');
    }

    public function test_products_follow_the_app_language(): void
    {
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
