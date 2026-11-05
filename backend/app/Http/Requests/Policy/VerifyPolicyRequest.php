<?php

namespace App\Http\Requests\Policy;

use App\Http\Requests\ApiRequest;

class VerifyPolicyRequest extends ApiRequest
{
    protected function numericInputs(): array
    {
        return ['policy_no', 'plate_no'];
    }

    protected function prepareForValidation(): void
    {
        parent::prepareForValidation();

        if (is_string($this->input('policy_no'))) {
            $this->merge(['policy_no' => strtoupper($this->input('policy_no'))]);
        }
    }

    public function rules(): array
    {
        return [
            'policy_no' => ['required', 'string', 'regex:'.config('insurance.validation.policy_no_regex')],
            'plate_no' => ['required', 'string', 'max:20'],
        ];
    }
}
