<?php

namespace App\Http\Requests\Vehicle;

use App\Enums\LicensePurpose;
use App\Enums\LicensingAuthority;
use App\Enums\ManufactureCountry;
use App\Enums\VehicleColor;
use App\Http\Requests\ApiRequest;
use App\Support\Digits;
use App\Support\PlateNumber;
use Illuminate\Validation\Rule;

class StoreVehicleRequest extends ApiRequest
{
    protected function numericInputs(): array
    {
        return ['year', 'engine_cc', 'seats'];
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
            'owner_name' => ['required', 'string', 'max:120'],
            'owner_address' => ['required', 'string', 'max:255'],
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
            'color' => ['required', Rule::enum(VehicleColor::class)],
            'country_of_origin' => ['required', Rule::enum(ManufactureCountry::class)],
            'license_purpose' => ['required', Rule::enum(LicensePurpose::class)],
            'seats' => ['required', 'integer', 'between:'.config('vehicles.seats.min').','.config('vehicles.seats.max')],
            'licensing_authority' => ['required', Rule::enum(LicensingAuthority::class)],
        ];
    }
}
