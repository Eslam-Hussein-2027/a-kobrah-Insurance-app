<?php

namespace App\Http\Requests\Vehicle;

use App\Http\Requests\ApiRequest;
use App\Support\Digits;
use App\Support\PlateNumber;
use Illuminate\Validation\Rule;

class StoreVehicleRequest extends ApiRequest
{
    protected function numericInputs(): array
    {
        return ['year', 'engine_cc'];
    }

    protected function prepareForValidation(): void
    {
        parent::prepareForValidation();

        $normalized = [];

        if (is_string($this->input('plate_no'))) {
            $normalized['plate_no'] = PlateNumber::format($this->input('plate_no'));
        }

        if (is_string($this->input('vin'))) {
            $normalized['vin'] = strtoupper((string) Digits::toWestern(str_replace(' ', '', $this->input('vin'))));
        }

        $this->merge($normalized);
    }

    public function rules(): array
    {
        return [
            'plate_no' => ['required', 'string', 'max:20'],
            'vin' => [
                'required',
                'string',
                'regex:'.config('insurance.validation.vin_regex'),
                Rule::unique('vehicles', 'vin')->ignore($this->route('vehicle')),
            ],
            'make' => ['required', 'string', 'max:50'],
            'model' => ['required', 'string', 'max:50'],
            'year' => [
                'required',
                'integer',
                'between:'.config('insurance.validation.min_vehicle_year').','.(now()->year + 1),
            ],
            'engine_cc' => ['required', 'integer', 'between:50,10000'],
        ];
    }
}
