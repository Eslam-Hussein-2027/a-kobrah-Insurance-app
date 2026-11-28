<?php

namespace App\Http\Requests\Auth;

use App\Http\Requests\ApiRequest;

class ResetPasswordRequest extends ApiRequest
{
    protected function numericInputs(): array
    {
        return ['code'];
    }

    public function rules(): array
    {
        return [
            'phone' => $this->phoneRules(),
            'code' => ['required', 'digits:'.config('insurance.otp.length')],
            'password' => PasswordRules::new(),
            'device_name' => ['required', 'string', 'max:100'],
        ];
    }
}
