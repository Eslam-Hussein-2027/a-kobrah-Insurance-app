<?php

namespace App\Http\Requests;

use App\Support\Digits;
use Illuminate\Foundation\Http\FormRequest;

abstract class ApiRequest extends FormRequest
{
    /**
     * Fields whose Arabic-Indic digits should be converted to Western digits before validation.
     *
     * @return list<string>
     */
    protected function numericInputs(): array
    {
        return [];
    }

    protected function prepareForValidation(): void
    {
        $normalized = [];

        foreach ($this->numericInputs() as $field) {
            if ($this->has($field)) {
                $normalized[$field] = Digits::toWestern($this->input($field));
            }
        }

        if ($normalized !== []) {
            $this->merge($normalized);
        }
    }

    /**
     * @return list<string>
     */
    protected function phoneRules(): array
    {
        return ['required', 'string', 'regex:'.config('insurance.validation.phone_regex')];
    }

    /**
     * @return list<string>
     */
    protected function imageRules(bool $required = false): array
    {
        return [
            $required ? 'required' : 'nullable',
            'file',
            'image',
            'mimes:'.implode(',', config('insurance.uploads.image_mimes')),
            'max:'.config('insurance.uploads.image_max_kb'),
        ];
    }
}
