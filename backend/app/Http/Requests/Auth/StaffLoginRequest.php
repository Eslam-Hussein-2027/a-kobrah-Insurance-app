<?php

namespace App\Http\Requests\Auth;

use App\Http\Requests\ApiRequest;

class StaffLoginRequest extends ApiRequest
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
