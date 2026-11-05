<?php

namespace App\Http\Resources\Admin;

use App\Http\Resources\CoverageTypeResource;
use App\Http\Resources\PaymentResource;
use App\Http\Resources\VehicleResource;
use App\Models\Policy;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/** @mixin Policy */
class AdminPolicyResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        $customer = $this->relationLoaded('vehicle') ? $this->vehicle->user : null;

        return [
            'id' => $this->id,
            'policy_no' => $this->policy_no,
            'status' => $this->status->toArray(),
            'start_date' => $this->start_date->toDateString(),
            'end_date' => $this->end_date->toDateString(),
            'premium' => $this->premium,
            'currency' => config('insurance.currency'),
            'issued_at' => $this->issued_at?->toIso8601String(),
            'customer' => $customer ? [
                'id' => $customer->id,
                'name' => $customer->name,
                'phone' => $customer->phone,
                'national_id' => $customer->national_id,
            ] : null,
            'vehicle' => new VehicleResource($this->whenLoaded('vehicle')),
            'coverage_type' => new CoverageTypeResource($this->whenLoaded('coverageType')),
            'payments' => PaymentResource::collection($this->whenLoaded('payments')),
            'pricing_snapshot' => $this->when($request->routeIs('api.v1.admin.policies.show'), $this->pricing_snapshot),
            'created_at' => $this->created_at?->toIso8601String(),
        ];
    }
}
