<?php

namespace App\Http\Requests\Auth;

use App\Http\Requests\ApiRequest;

/** Phone + password, for customers (app) and staff (dashboard). */
class LoginRequest extends ApiRequest
{
    public function rules(): array
    {
        return [
            'phone' => $this->phoneRules(),
            'password' => ['required', 'string', 'max:100'],
            'device_name' => ['required', 'string', 'max:100'],
        ];
    }
}
