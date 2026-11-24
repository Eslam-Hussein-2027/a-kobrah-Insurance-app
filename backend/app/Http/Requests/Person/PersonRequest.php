<?php

namespace App\Http\Requests\Person;

use App\Enums\PersonRelationship;
use App\Http\Requests\ApiRequest;
use App\Support\Digits;
use Illuminate\Validation\Rule;

/** Create and update an insured person (all fields are sent each time). */
class PersonRequest extends ApiRequest
{
    protected function numericInputs(): array
    {
        return ['national_id'];
    }

    protected function prepareForValidation(): void
    {
        parent::prepareForValidation();

        if (is_string($this->input('passport_no'))) {
            $this->merge([
                'passport_no' => strtoupper((string) Digits::toWestern(str_replace(' ', '', $this->input('passport_no')))) ?: null,
            ]);
        }

        if (is_string($this->input('full_name'))) {
            $this->merge(['full_name' => preg_replace('/\s+/u', ' ', trim($this->input('full_name')))]);
        }
    }

    public function rules(): array
    {
        return [
            'full_name' => ['required', 'string', 'min:3', 'max:100'],
            'relationship' => ['required', Rule::enum(PersonRelationship::class)],
            'birth_date' => ['required', 'date_format:Y-m-d', 'after:1900-01-01', 'before_or_equal:today'],
            'passport_no' => ['nullable', 'string', 'regex:/^[A-Z0-9]{5,20}$/'],
            'national_id' => ['nullable', 'string', 'regex:'.config('insurance.validation.national_id_regex')],
        ];
    }

    /**
     * Full replacement: optional documents left out of the form are cleared.
     *
     * @return array<string, mixed>
     */
    public function personData(): array
    {
        return array_merge(['passport_no' => null, 'national_id' => null], $this->validated());
    }
}
