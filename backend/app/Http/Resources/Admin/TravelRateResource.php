<?php

namespace App\Http\Resources\Admin;

use App\Models\TravelRate;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/** @mixin TravelRate */
class TravelRateResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'zone' => $this->zone->toArray(),
            'days' => $this->days,
            'price' => $this->price,
            'is_active' => $this->is_active,
        ];
    }
}
