<?php

namespace App\Http\Requests\Auth;

/** Rules for a new customer password (registration, reset, change). */
final class PasswordRules
{
    /**
     * @return list<string>
     */
    public static function new(): array
    {
        return ['required', 'string', 'min:'.config('insurance.auth.password_min_length'), 'max:100', 'confirmed'];
    }
}
