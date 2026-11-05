<?php

namespace App\Http\Resources;

use App\Enums\UserDocumentType;
use App\Models\User;
use App\Services\UserDocumentService;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/** @mixin User */
class UserResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        $documents = app(UserDocumentService::class);

        return [
            'id' => $this->id,
            'name' => $this->name,
            'phone' => $this->phone,
            'national_id' => $this->national_id,
            'role' => $this->role->toArray(),
            'phone_verified_at' => $this->phone_verified_at?->toIso8601String(),
            'documents' => collect(UserDocumentType::cases())->mapWithKeys(fn (UserDocumentType $type) => [
                $type->value => [
                    'uploaded' => $this->documentPath($type) !== null,
                    // Short-lived signed URL; the file itself lives on a private disk.
                    'url' => $documents->temporaryUrl($this->resource, $type),
                ],
            ])->all(),
            'kyc_completed' => $this->hasKycDocuments(),
            'created_at' => $this->created_at?->toIso8601String(),
        ];
    }
}
