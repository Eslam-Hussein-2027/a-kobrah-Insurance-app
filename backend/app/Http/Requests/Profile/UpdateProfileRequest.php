<?php

namespace App\Http\Requests\Profile;

use App\Http\Requests\ApiRequest;
use Illuminate\Validation\Rule;

/** Personal information the customer completes after sign-up (needed before issuing a policy). */
class UpdateProfileRequest extends ApiRequest
{
    protected function numericInputs(): array
    {
        return ['national_id'];
    }

    public function rules(): array
    {
        return [
            'national_id' => [
                'sometimes',
                'required',
                'string',
                'regex:'.config('insurance.validation.national_id_regex'),
                Rule::unique('users', 'national_id')->ignore($this->user()),
            ],
            'address' => ['sometimes', 'required', 'string', 'max:255'],
        ];
    }
}
