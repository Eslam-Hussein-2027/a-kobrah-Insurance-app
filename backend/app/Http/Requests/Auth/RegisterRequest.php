<?php

namespace App\Http\Requests\Auth;

use App\Http\Requests\ApiRequest;

class RegisterRequest extends ApiRequest
{
    protected function numericInputs(): array
    {
        return ['national_id'];
    }

    public function rules(): array
    {
        return [
            'registration_token' => ['required', 'string', 'size:64'],
            'name' => ['required', 'string', 'min:3', 'max:100'],
            'national_id' => [
                'required',
                'string',
                'regex:'.config('insurance.validation.national_id_regex'),
                'unique:users,national_id',
            ],
            'device_name' => ['required', 'string', 'max:100'],
            'id_image' => $this->imageRules(),
            'license_image' => $this->imageRules(),
        ];
    }
}
