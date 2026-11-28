<?php

namespace App\Http\Requests\Auth;

use App\Http\Requests\ApiRequest;

class ChangePasswordRequest extends ApiRequest
{
    public function rules(): array
    {
        return [
            'current_password' => ['required', 'string', 'max:100'],
            'password' => [...PasswordRules::new(), 'different:current_password'],
        ];
    }
}
