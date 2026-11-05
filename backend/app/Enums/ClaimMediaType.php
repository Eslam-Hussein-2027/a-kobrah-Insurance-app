<?php

namespace App\Enums;

use App\Enums\Concerns\HasLabel;

enum ClaimMediaType: string
{
    use HasLabel;

    case Damage = 'DAMAGE';
    case PoliceReport = 'POLICE_REPORT';

    public static function translationGroup(): string
    {
        return 'claim_media_type';
    }
}
