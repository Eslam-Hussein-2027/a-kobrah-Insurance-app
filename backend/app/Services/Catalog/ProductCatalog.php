<?php

namespace App\Services\Catalog;

use App\Enums\InsuranceProduct;

/**
 * Builds the localized product catalog from config/products.php + lang/{locale}/products.php.
 */
class ProductCatalog
{
    /**
     * @return list<array<string, mixed>>
     */
    public function all(): array
    {
        return array_map(fn (InsuranceProduct $product) => $this->describe($product), InsuranceProduct::offered());
    }

    /**
     * @return array<string, mixed>
     */
    public function describe(InsuranceProduct $product): array
    {
        $code = $product->value;

        return [
            'code' => $code,
            'name' => $product->label(),
            'title' => __("products.{$code}.title"),
            'description' => __("products.{$code}.description"),
            'issuance' => $product->isInstant() ? 'instant' : 'request',
            'icon' => (string) config("products.items.{$code}.icon"),
            'covers' => (array) __("products.{$code}.covers"),
            'documents' => array_map(
                fn (string $key) => ['key' => $key, 'label' => $this->documentLabel($key)],
                $this->documentKeys($product),
            ),
            'fields' => array_map(fn (array $field) => [
                'key' => $field['key'],
                'label' => $this->fieldLabel($field['key']),
                'type' => $field['type'],
                'required' => (bool) $field['required'],
                'min' => $field['min'] ?? null,
                'max' => $field['max'] ?? null,
            ], $this->fields($product)),
        ];
    }

    /**
     * Form fields of a request product.
     *
     * @return list<array{key: string, type: string, required: bool, min?: int|float, max?: int|float}>
     */
    public function fields(InsuranceProduct $product): array
    {
        return array_values((array) config("products.items.{$product->value}.fields", []));
    }

    /**
     * @return list<string>
     */
    public function documentKeys(InsuranceProduct $product): array
    {
        return array_values((array) config("products.items.{$product->value}.documents", []));
    }

    public function fieldLabel(string $key): string
    {
        return __("products.fields.{$key}");
    }

    public function documentLabel(string $key): string
    {
        return __("products.documents.{$key}");
    }
}
