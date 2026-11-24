<?php

namespace App\Enums;

use App\Enums\Concerns\HasLabel;

/**
 * SUBMITTED → IN_REVIEW → QUOTED → COMPLETED
 *                ↘ REJECTED      ↘ (customer) CANCELLED
 */
enum InsuranceRequestStatus: string
{
    use HasLabel;

    case Submitted = 'SUBMITTED';
    case InReview = 'IN_REVIEW';
    case Quoted = 'QUOTED';
    case Completed = 'COMPLETED';
    case Rejected = 'REJECTED';
    case Cancelled = 'CANCELLED';

    public static function translationGroup(): string
    {
        return 'insurance_request_status';
    }

    public function isOpen(): bool
    {
        return in_array($this, [self::Submitted, self::InReview, self::Quoted], true);
    }

    /** The customer may withdraw a request until staff close it. */
    public function canBeCancelledByCustomer(): bool
    {
        return $this->isOpen();
    }

    /**
     * Statuses staff can move an open request to.
     *
     * @return list<self>
     */
    public static function staffTargets(): array
    {
        return [self::InReview, self::Quoted, self::Completed, self::Rejected];
    }
}
