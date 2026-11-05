<?php

namespace App\Http\Requests\Auth;

use App\Http\Requests\ApiRequest;

class SendOtpRequest extends ApiRequest
{
    protected function numericInputs(): array
    {
        return ['phone'];
    }

    public function rules(): array
    {
        return [
            'phone' => $this->phoneRules(),
        ];
    }
}
