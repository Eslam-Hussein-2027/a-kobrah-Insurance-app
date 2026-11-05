<?php

namespace Tests\Unit;

use App\Enums\ClaimStatus;
use PHPUnit\Framework\TestCase;

/**
 * Transition rules are defined now (schema phase); the claim workflow endpoints arrive in phase 3.
 */
class ClaimStatusTest extends TestCase
{
    public function test_happy_path_is_strictly_sequential(): void
    {
        $path = [
            ClaimStatus::Submitted,
            ClaimStatus::UnderReview,
            ClaimStatus::SurveyorAssigned,
            ClaimStatus::Inspected,
            ClaimStatus::Approved,
            ClaimStatus::InRepair,
            ClaimStatus::Settled,
            ClaimStatus::Closed,
        ];

        for ($i = 0; $i < count($path) - 1; $i++) {
            $this->assertTrue($path[$i]->canTransitionTo($path[$i + 1]), "{$path[$i]->value} → {$path[$i + 1]->value}");
        }
    }

    public function test_steps_cannot_be_skipped_or_reversed(): void
    {
        $this->assertFalse(ClaimStatus::Submitted->canTransitionTo(ClaimStatus::Approved));
        $this->assertFalse(ClaimStatus::UnderReview->canTransitionTo(ClaimStatus::Inspected));
        $this->assertFalse(ClaimStatus::Approved->canTransitionTo(ClaimStatus::UnderReview));
        $this->assertFalse(ClaimStatus::Settled->canTransitionTo(ClaimStatus::InRepair));
    }

    public function test_only_review_stages_can_be_rejected(): void
    {
        foreach ([ClaimStatus::Submitted, ClaimStatus::UnderReview, ClaimStatus::SurveyorAssigned, ClaimStatus::Inspected] as $status) {
            $this->assertTrue($status->canTransitionTo(ClaimStatus::Rejected), $status->value);
        }

        foreach ([ClaimStatus::Approved, ClaimStatus::InRepair, ClaimStatus::Settled, ClaimStatus::Closed] as $status) {
            $this->assertFalse($status->canTransitionTo(ClaimStatus::Rejected), $status->value);
        }
    }

    public function test_terminal_states_and_rejection_reason(): void
    {
        $this->assertTrue(ClaimStatus::Closed->isTerminal());
        $this->assertTrue(ClaimStatus::Rejected->isTerminal());
        $this->assertFalse(ClaimStatus::Settled->isTerminal());

        $this->assertTrue(ClaimStatus::Rejected->requiresReason());
        $this->assertFalse(ClaimStatus::Approved->requiresReason());
    }
}
