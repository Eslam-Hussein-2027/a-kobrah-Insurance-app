<?php

namespace App\Http\Requests\Payment;

use App\Http\Requests\ApiRequest;

class ConfirmPaymentRequest extends ApiRequest
{
    protected function numericInputs(): array
    {
        return ['otp'];
    }

    public function rules(): array
    {
        return [
            'otp' => ['required', 'string', 'regex:/^[0-9]{4,8}$/'],
        ];
    }
}
