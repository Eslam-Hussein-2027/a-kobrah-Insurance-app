<?php

namespace App\Http\Requests\Vehicle;

/**
 * Same rules as create, but every field is optional (PATCH semantics).
 */
class UpdateVehicleRequest extends StoreVehicleRequest
{
    public function rules(): array
    {
        return collect(parent::rules())
            ->map(fn (array $rules) => ['sometimes', ...array_filter($rules, fn ($rule) => $rule !== 'required')])
            ->all();
    }
}
