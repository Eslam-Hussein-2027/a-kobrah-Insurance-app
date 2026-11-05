<?php

namespace App\Http\Requests\Quote;

use App\Http\Requests\ApiRequest;

class QuoteRequest extends ApiRequest
{
    public function rules(): array
    {
        return [
            'vehicle_id' => ['required', 'integer', 'exists:vehicles,id'],
            'coverage_type_id' => ['required', 'integer', 'exists:coverage_types,id'],
        ];
    }
}
