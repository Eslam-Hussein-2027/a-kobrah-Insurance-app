<?php

namespace App\Http\Controllers\Api\V1;

use App\Enums\UserDocumentType;
use App\Http\Controllers\Controller;
use App\Models\InsuranceRequestDocument;
use App\Models\User;
use App\Services\Requests\InsuranceRequestService;
use App\Services\UserDocumentService;
use Symfony\Component\HttpFoundation\StreamedResponse;

/**
 * Serves private files. Access is granted by the URL signature (temporary signed route),
 * so images can be loaded directly by the mobile app / dashboard <img> tags.
 */
class FileController extends Controller
{
    public function userDocument(User $user, string $type, UserDocumentService $documents): StreamedResponse
    {
        $path = $user->documentPath(UserDocumentType::from($type));

        abort_if($path === null || ! $documents->disk()->exists($path), 404);

        return $documents->disk()->response($path, null, [
            'Cache-Control' => 'private, max-age=600',
            'X-Content-Type-Options' => 'nosniff',
        ]);
    }

    public function requestDocument(InsuranceRequestDocument $document, InsuranceRequestService $requests): StreamedResponse
    {
        abort_unless($requests->disk()->exists($document->path), 404);

        return $requests->disk()->response($document->path, $document->original_name, [
            'Cache-Control' => 'private, max-age=600',
            'X-Content-Type-Options' => 'nosniff',
        ]);
    }
}
