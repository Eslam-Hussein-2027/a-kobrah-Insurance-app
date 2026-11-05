<?php

namespace App\Enums;

use App\Enums\Concerns\HasLabel;

/**
 * KYC documents stored on the users table. The value is the column name.
 */
enum UserDocumentType: string
{
    use HasLabel;

    case IdImage = 'id_image';
    case LicenseImage = 'license_image';

    public static function translationGroup(): string
    {
        return 'user_document_type';
    }
}
