<?php

namespace App\Enums;

use App\Enums\Concerns\HasLabel;

/**
 * SUBMITTED → UNDER_REVIEW → SURVEYOR_ASSIGNED → INSPECTED → APPROVED → IN_REPAIR → SETTLED → CLOSED
 * Any review stage (SUBMITTED .. INSPECTED) → REJECTED (reason mandatory).
 */
enum ClaimStatus: string
{
    use HasLabel;

    case Submitted = 'SUBMITTED';
    case UnderReview = 'UNDER_REVIEW';
    case SurveyorAssigned = 'SURVEYOR_ASSIGNED';
    case Inspected = 'INSPECTED';
    case Approved = 'APPROVED';
    case InRepair = 'IN_REPAIR';
    case Settled = 'SETTLED';
    case Closed = 'CLOSED';
    case Rejected = 'REJECTED';

    public static function translationGroup(): string
    {
        return 'claim_status';
    }

    /**
     * @return list<self>
     */
    public function allowedTransitions(): array
    {
        return match ($this) {
            self::Submitted => [self::UnderReview, self::Rejected],
            self::UnderReview => [self::SurveyorAssigned, self::Rejected],
            self::SurveyorAssigned => [self::Inspected, self::Rejected],
            self::Inspected => [self::Approved, self::Rejected],
            self::Approved => [self::InRepair],
            self::InRepair => [self::Settled],
            self::Settled => [self::Closed],
            self::Closed, self::Rejected => [],
        };
    }

    public function canTransitionTo(self $target): bool
    {
        return in_array($target, $this->allowedTransitions(), true);
    }

    public function isTerminal(): bool
    {
        return $this->allowedTransitions() === [];
    }

    public function requiresReason(): bool
    {
        return $this === self::Rejected;
    }
}
