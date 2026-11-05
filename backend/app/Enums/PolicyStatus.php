<?php

namespace App\Enums;

use App\Enums\Concerns\HasLabel;

enum PolicyStatus: string
{
    use HasLabel;

    case PendingPayment = 'PENDING_PAYMENT';
    case Active = 'ACTIVE';
    case Expired = 'EXPIRED';
    case Cancelled = 'CANCELLED';

    public static function translationGroup(): string
    {
        return 'policy_status';
    }

    /**
     * Statuses that "occupy" a vehicle's coverage period (used for overlap checks).
     *
     * @return list<self>
     */
    public static function blocking(): array
    {
        return [self::PendingPayment, self::Active];
    }
}
