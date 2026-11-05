<?php

namespace App\Enums;

use App\Enums\Concerns\HasLabel;

enum PaymentStatus: string
{
    use HasLabel;

    case Pending = 'PENDING';
    case Paid = 'PAID';
    case Failed = 'FAILED';
    case Refunded = 'REFUNDED';

    public static function translationGroup(): string
    {
        return 'payment_status';
    }
}
