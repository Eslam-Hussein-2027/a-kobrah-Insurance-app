<?php

namespace App\Http\Resources\Admin;

use App\Models\PricingFactor;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/** @mixin PricingFactor */
class PricingFactorResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'factor_type' => $this->factor_type->toArray(),
            'min_value' => $this->min_value,
            'max_value' => $this->max_value,
            'multiplier' => $this->multiplier,
        ];
    }
}
