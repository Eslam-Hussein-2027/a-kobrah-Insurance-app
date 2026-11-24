<?php

namespace App\Http\Requests\Quote;

use App\Http\Requests\ApiRequest;

class EstimateQuoteRequest extends ApiRequest
{
    protected function numericInputs(): array
    {
        return ['manufacture_year', 'engine_cc'];
    }

    public function rules(): array
    {
        return [
            'manufacture_year' => [
                'required',
                'integer',
                'between:'.config('insurance.validation.min_vehicle_year').','.(now()->year + 1),
            ],
            'engine_cc' => ['required', 'integer', 'between:50,10000'],
            // Defaults to the compulsory (mandatory) coverage.
            'coverage_type_id' => ['nullable', 'integer', 'exists:coverage_types,id'],
        ];
    }
}
