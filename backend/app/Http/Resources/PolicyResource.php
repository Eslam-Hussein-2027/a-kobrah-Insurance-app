<?php

namespace App\Http\Resources;

use App\Enums\PolicyStatus;
use App\Models\Policy;
use App\Models\PolicyTraveller;
use App\Services\Policy\PolicyVerificationService;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/** @mixin Policy */
class PolicyResource extends JsonResource
{
    /** Relations every endpoint loads before returning this resource. */
    public const RELATIONS = ['vehicle', 'coverageType', 'travellers'];

    public function toArray(Request $request): array
    {
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
            'previous_policy_id' => $this->previous_policy_id,
            // Motor only.
            'vehicle' => $this->when($this->vehicle_id !== null, fn () => new VehicleResource($this->whenLoaded('vehicle')), null),
            'coverage_type' => $this->when(
                $this->coverage_type_id !== null,
                fn () => new CoverageTypeResource($this->whenLoaded('coverageType')),
                null,
            ),
            // Travel only.
            'travel' => $this->when($this->isTravel(), fn () => self::travelData($this->resource), null),
            'can_download_pdf' => $this->isActive(),
            'pdf_url' => $this->when(
                $this->isActive(),
                fn () => route('api.v1.policies.pdf', $this->resource),
            ),
            // Same link as the QR printed on the policy (issued policies only).
            'verification_url' => $this->when(
                in_array($this->status, [PolicyStatus::Active, PolicyStatus::Expired], true),
                fn () => app(PolicyVerificationService::class)->url($this->resource),
            ),
            'created_at' => $this->created_at?->toIso8601String(),
        ];
    }

    /**
     * @return array<string, mixed>
     */
    public static function travelData(Policy $policy): array
    {
        return [
            'zone' => $policy->travel_zone?->toArray(),
            'days' => $policy->travel_days,
            'travellers' => $policy->relationLoaded('travellers')
                ? $policy->travellers->map(fn (PolicyTraveller $traveller) => [
                    'full_name' => $traveller->full_name,
                    'birth_date' => $traveller->birth_date->toDateString(),
                    'passport_no' => $traveller->passport_no,
                ])->values()->all()
                : [],
        ];
    }
}
