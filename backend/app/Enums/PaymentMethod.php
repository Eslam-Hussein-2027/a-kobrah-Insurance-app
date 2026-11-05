<?php

namespace App\Enums;

use App\Enums\Concerns\HasLabel;

enum PaymentMethod: string
{
    use HasLabel;

    case Online = 'ONLINE';
    case Office = 'OFFICE';

    public static function translationGroup(): string
    {
        return 'payment_method';
    }
}
