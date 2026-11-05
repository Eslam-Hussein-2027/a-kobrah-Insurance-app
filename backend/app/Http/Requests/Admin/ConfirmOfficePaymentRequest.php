<?php

namespace App\Http\Requests\Admin;

use App\Http\Requests\ApiRequest;

class ConfirmOfficePaymentRequest extends ApiRequest
{
    public function rules(): array
    {
        return [
            // Office receipt / POS reference number.
            'reference' => ['nullable', 'string', 'max:100'],
        ];
    }
}
