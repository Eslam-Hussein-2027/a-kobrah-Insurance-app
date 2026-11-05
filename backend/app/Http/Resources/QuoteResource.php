<?php

namespace App\Http\Resources;

use App\Services\Pricing\Quote;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/** @property Quote $resource */
class QuoteResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        $quote = $this->resource;

        return [
            'vehicle' => new VehicleResource($quote->vehicle),
            'coverage_type' => new CoverageTypeResource($quote->coverageType),
            'base_price' => $quote->basePrice,
            'factors' => array_map(fn (array $factor) => [
                'type' => $factor['type']->value,
                'label' => $factor['type']->label(),
                'input' => $factor['input'],
                'multiplier' => $factor['multiplier'],
            ], $quote->factors),
            'premium' => $quote->premium,
            'currency' => $quote->currency,
            'calculated_at' => $quote->calculatedAt->toIso8601String(),
        ];
    }
}
