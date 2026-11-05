<?php

namespace App\Enums;

use App\Enums\Concerns\HasLabel;

enum PolicyVerificationResult: string
{
    use HasLabel;

    case Valid = 'VALID';
    case Expired = 'EXPIRED';
    case NotFound = 'NOT_FOUND';

    public static function translationGroup(): string
    {
        return 'policy_verification';
    }
}
