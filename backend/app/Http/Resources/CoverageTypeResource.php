<?php

namespace App\Http\Resources;

use App\Models\CoverageType;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/** @mixin CoverageType */
class CoverageTypeResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'code' => $this->code,
            'name' => $this->localizedName(),
            'description' => $this->description,
            'base_price' => $this->base_price,
            'currency' => config('insurance.currency'),
            'is_mandatory' => $this->is_mandatory,
        ];
    }
}
