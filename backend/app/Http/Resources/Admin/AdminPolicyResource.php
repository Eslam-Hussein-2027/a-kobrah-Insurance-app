<?php

namespace App\Http\Resources\Admin;

use App\Enums\PolicyStatus;
use App\Http\Resources\CoverageTypeResource;
use App\Http\Resources\PaymentResource;
use App\Http\Resources\PolicyResource;
use App\Http\Resources\VehicleResource;
use App\Models\Policy;
use App\Services\Policy\PolicyVerificationService;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/** @mixin Policy */
class AdminPolicyResource extends JsonResource
{
    public const RELATIONS = ['user', 'vehicle', 'coverageType', 'travellers'];

    public function toArray(Request $request): array
    {
        $customer = $this->relationLoaded('user') ? $this->user : null;

        return [
            'id' => $this->id,
            'policy_no' => $this->policy_no,
            'product' => $this->product->toArray(),
            'title' => $this->displayName(),
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
            'vehicle' => $this->when($this->vehicle_id !== null, fn () => new VehicleResource($this->whenLoaded('vehicle')), null),
            'coverage_type' => $this->when(
                $this->coverage_type_id !== null,
                fn () => new CoverageTypeResource($this->whenLoaded('coverageType')),
                null,
            ),
            'travel' => $this->when($this->isTravel(), fn () => PolicyResource::travelData($this->resource), null),
            'payments' => PaymentResource::collection($this->whenLoaded('payments')),
            'pricing_snapshot' => $this->when($request->routeIs('api.v1.admin.policies.show'), $this->pricing_snapshot),
            // Same link as the QR printed on the policy (issued policies only).
            'verification_url' => $this->when(
                in_array($this->status, [PolicyStatus::Active, PolicyStatus::Expired], true),
                fn () => app(PolicyVerificationService::class)->url($this->resource),
            ),
            'created_at' => $this->created_at?->toIso8601String(),
        ];
    }
}
