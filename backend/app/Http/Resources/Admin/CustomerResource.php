<?php

namespace App\Http\Resources\Admin;

use App\Enums\UserDocumentType;
use App\Http\Resources\VehicleResource;
use App\Models\User;
use App\Services\UserDocumentService;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/** @mixin User */
class CustomerResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        $documents = app(UserDocumentService::class);

        return [
            'id' => $this->id,
            'name' => $this->name,
            'phone' => $this->phone,
            'national_id' => $this->national_id,
            'is_active' => $this->is_active,
            'kyc_completed' => $this->hasKycDocuments(),
            'vehicles_count' => $this->whenCounted('vehicles'),
            'policies_count' => $this->whenCounted('policies'),
            'documents' => collect(UserDocumentType::cases())->mapWithKeys(fn (UserDocumentType $type) => [
                $type->value => [
                    'label' => $type->label(),
                    'uploaded' => $this->documentPath($type) !== null,
                    'url' => $documents->temporaryUrl($this->resource, $type),
                ],
            ])->all(),
            'vehicles' => VehicleResource::collection($this->whenLoaded('vehicles')),
            'policies' => AdminPolicyResource::collection($this->whenLoaded('policies')),
            'created_at' => $this->created_at?->toIso8601String(),
        ];
    }
}
