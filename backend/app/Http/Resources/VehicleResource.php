<?php

namespace App\Http\Resources;

use App\Models\Vehicle;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/** @mixin Vehicle */
class VehicleResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'owner_name' => $this->owner_name,
            'owner_address' => $this->owner_address,
            'plate_no' => $this->plate_no,
            'vin' => $this->vin,
            'make' => $this->make,
            'model' => $this->model,
            'year' => $this->year,
            'engine_cc' => $this->engine_cc,
            'color' => $this->color?->toArray(),
            'country_of_origin' => $this->country_of_origin?->toArray(),
            'license_purpose' => $this->license_purpose?->toArray(),
            'seats' => $this->seats,
            'licensing_authority' => $this->licensing_authority?->toArray(),
            'details_complete' => $this->hasRegistrationDetails(),
            'age_years' => $this->ageInYears(),
            'created_at' => $this->created_at?->toIso8601String(),
            'updated_at' => $this->updated_at?->toIso8601String(),
        ];
    }
}
