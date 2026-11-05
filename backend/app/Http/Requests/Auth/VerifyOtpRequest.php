<?php

namespace App\Http\Requests\Auth;

use App\Http\Requests\ApiRequest;

class VerifyOtpRequest extends ApiRequest
{
    protected function numericInputs(): array
    {
        return ['phone', 'code'];
    }

    public function rules(): array
    {
        return [
            'phone' => $this->phoneRules(),
            'code' => ['required', 'string', 'digits:'.config('insurance.otp.length')],
            'device_name' => ['required', 'string', 'max:100'],
        ];
    }
}
