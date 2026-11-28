<?php

namespace App\Http\Requests\Auth;

use App\Http\Requests\ApiRequest;
use Illuminate\Validation\Rule;

/**
 * Account sign-up. "code" is the SMS code, sent on the second call when phone verification is on.
 */
class RegisterRequest extends ApiRequest
{
    protected function numericInputs(): array
    {
        return ['code'];
    }

    public function rules(): array
    {
        return [
            'first_name' => ['required', 'string', 'min:2', 'max:50'],
            'last_name' => ['required', 'string', 'min:2', 'max:50'],
            'phone' => [...$this->phoneRules(), Rule::unique('users', 'phone')],
            'address' => ['required', 'string', 'max:255'],
            'password' => PasswordRules::new(),
            'device_name' => ['required', 'string', 'max:100'],
            'code' => ['nullable', 'digits:'.config('insurance.otp.length')],
        ];
    }

    public function messages(): array
    {
        return ['phone.unique' => __('messages.auth.phone_taken')];
    }
}
