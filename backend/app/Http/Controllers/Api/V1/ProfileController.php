<?php

namespace App\Http\Controllers\Api\V1;

use App\Enums\UserDocumentType;
use App\Http\Controllers\Controller;
use App\Http\Requests\Profile\UploadDocumentsRequest;
use App\Http\Resources\UserResource;
use App\Http\Responses\ApiResponse;
use App\Services\UserDocumentService;
use Illuminate\Http\JsonResponse;

class ProfileController extends Controller
{
    public function uploadDocuments(UploadDocumentsRequest $request, UserDocumentService $documents): JsonResponse
    {
        $user = $request->user();

        foreach (UserDocumentType::cases() as $type) {
            if ($request->hasFile($type->value)) {
                $documents->store($user, $type, $request->file($type->value));
            }
        }

        return ApiResponse::success(new UserResource($user->refresh()), __('messages.profile.documents_uploaded'));
    }
}
