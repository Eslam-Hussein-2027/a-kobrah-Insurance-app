<?php

namespace App\Services;

use App\Enums\UserDocumentType;
use App\Models\User;
use Illuminate\Contracts\Filesystem\Filesystem;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\URL;

/**
 * KYC images (national ID, driving license) on a private disk, exposed only via temporary signed URLs.
 */
class UserDocumentService
{
    public function store(User $user, UserDocumentType $type, UploadedFile $file): string
    {
        $path = $file->store("users/{$user->id}/documents", ['disk' => $this->diskName()]);
        $previous = $user->documentPath($type);

        $user->forceFill([$type->value => $path])->save();

        if ($previous !== null && $previous !== $path) {
            $this->disk()->delete($previous);
        }

        return $path;
    }

    public function temporaryUrl(User $user, UserDocumentType $type): ?string
    {
        if ($user->documentPath($type) === null) {
            return null;
        }

        return URL::temporarySignedRoute(
            'api.v1.files.user-document',
            now()->addMinutes((int) config('insurance.uploads.signed_url_ttl_minutes')),
            ['user' => $user->id, 'type' => $type->value],
        );
    }

    public function disk(): Filesystem
    {
        return Storage::disk($this->diskName());
    }

    private function diskName(): string
    {
        return (string) config('insurance.uploads.disk');
    }
}
