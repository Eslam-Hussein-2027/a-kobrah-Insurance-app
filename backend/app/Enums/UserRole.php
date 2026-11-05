<?php

namespace App\Enums;

use App\Enums\Concerns\HasLabel;

enum UserRole: string
{
    use HasLabel;

    case Customer = 'customer';
    case Surveyor = 'surveyor';
    case Admin = 'admin';
    case Workshop = 'workshop';

    public static function translationGroup(): string
    {
        return 'user_role';
    }
}
