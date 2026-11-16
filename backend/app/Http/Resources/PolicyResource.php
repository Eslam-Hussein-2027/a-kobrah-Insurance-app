<?php

namespace App\Http\Resources;

use App\Enums\PolicyStatus;
use App\Models\Policy;
use App\Services\Policy\PolicyVerificationService;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/** @mixin Policy */
class PolicyResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'policy_no' => $this->policy_no,
            'status' => $this->status->toArray(),
            'start_date' => $this->start_date->toDateString(),
            'end_date' => $this->end_date->toDateString(),
            'premium' => $this->premium,
            'currency' => config('insurance.currency'),
            'issued_at' => $this->issued_at?->toIso8601String(),
            'previous_policy_id' => $this->previous_policy_id,
            'vehicle' => new VehicleResource($this->whenLoaded('vehicle')),
            'coverage_type' => new CoverageTypeResource($this->whenLoaded('coverageType')),
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
}
