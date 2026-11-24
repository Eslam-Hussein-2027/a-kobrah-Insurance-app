<?php

namespace App\Http\Requests\InsuranceRequest;

use App\Enums\InsuranceProduct;
use App\Enums\InsuranceRequestKind;
use App\Http\Requests\ApiRequest;
use App\Services\Catalog\ProductCatalog;
use App\Support\Digits;
use Illuminate\Http\UploadedFile;
use Illuminate\Validation\Rule;

/**
 * multipart/form-data:
 *   product, kind, notes?, answers[<field>]=..., documents[<document_key>]=<file>
 * Field rules are built from the product's definition in config/products.php.
 */
class StoreInsuranceRequestRequest extends ApiRequest
{
    protected function prepareForValidation(): void
    {
        parent::prepareForValidation();

        $answers = $this->input('answers');

        if (is_array($answers)) {
            $this->merge(['answers' => array_map(
                fn ($value) => is_string($value) ? trim((string) Digits::toWestern($value)) : $value,
                $answers,
            )]);
        }
    }

    public function rules(): array
    {
        $requestProducts = array_map(fn (InsuranceProduct $p) => $p->value, InsuranceProduct::onRequest());

        $rules = [
            'product' => ['required', 'string', Rule::in($requestProducts)],
            'kind' => ['required', Rule::enum(InsuranceRequestKind::class)],
            'notes' => ['nullable', 'string', 'max:'.config('products.request.notes_max')],
            'answers' => ['nullable', 'array'],
            'documents' => ['nullable', 'array'],
        ];

        $product = InsuranceProduct::tryFrom((string) $this->input('product'));

        if ($product === null || $product->isInstant()) {
            return $rules;
        }

        $catalog = app(ProductCatalog::class);

        foreach ($catalog->fields($product) as $field) {
            $rules['answers.'.$field['key']] = $this->fieldRules($field);
        }

        $documentRules = [
            'nullable',
            'file',
            'mimes:'.implode(',', (array) config('products.request.document_mimes')),
            'max:'.config('products.request.document_max_kb'),
        ];

        foreach ($catalog->documentKeys($product) as $key) {
            $rules['documents.'.$key] = $documentRules;
        }

        return $rules;
    }

    public function attributes(): array
    {
        $product = InsuranceProduct::tryFrom((string) $this->input('product'));

        if ($product === null) {
            return [];
        }

        $catalog = app(ProductCatalog::class);
        $attributes = [];

        foreach ($catalog->fields($product) as $field) {
            $attributes['answers.'.$field['key']] = $catalog->fieldLabel($field['key']);
        }

        foreach ($catalog->documentKeys($product) as $key) {
            $attributes['documents.'.$key] = $catalog->documentLabel($key);
        }

        return $attributes;
    }

    public function product(): InsuranceProduct
    {
        return InsuranceProduct::from($this->validated('product'));
    }

    public function kind(): InsuranceRequestKind
    {
        return InsuranceRequestKind::from($this->validated('kind'));
    }

    /**
     * Only files for the product's known document keys.
     *
     * @return array<string, UploadedFile>
     */
    public function documents(): array
    {
        $keys = app(ProductCatalog::class)->documentKeys($this->product());

        return array_filter(
            array_intersect_key((array) $this->file('documents', []), array_flip($keys)),
        );
    }

    /**
     * @param  array{key: string, type: string, required: bool, min?: int|float, max?: int|float}  $field
     * @return list<mixed>
     */
    private function fieldRules(array $field): array
    {
        $rules = [$field['required'] ? 'required' : 'nullable'];

        $rules = [...$rules, ...match ($field['type']) {
            'integer' => ['integer'],
            'number' => ['numeric'],
            'date' => ['date_format:Y-m-d', 'after_or_equal:today'],
            'vehicle' => ['integer', Rule::exists('vehicles', 'id')->where('user_id', $this->user()?->id)],
            default => ['string'],
        }];

        if (isset($field['min'])) {
            $rules[] = 'min:'.$field['min'];
        }

        if (isset($field['max'])) {
            $rules[] = 'max:'.$field['max'];
        }

        return $rules;
    }
}
