<?php

namespace App\Services\Policy;

use App\Enums\PolicyStatus;
use App\Enums\PolicyVerificationResult;
use App\Models\Policy;
use App\Support\PlateNumber;
use Carbon\CarbonImmutable;

/**
 * Public verification (police, other drivers, workshops). Requires BOTH policy_no and plate_no,
 * and never exposes personal data.
 */
class PolicyVerificationService
{
    /**
     * @return array{result: PolicyVerificationResult, policy: ?Policy}
     */
    public function verify(string $policyNo, string $plateNo): array
    {
        $policy = Policy::query()
            ->with(['vehicle:id,plate_no', 'coverageType:id,code,name,name_en'])
            ->where('policy_no', strtoupper(trim($policyNo)))
            ->first();

        if ($policy === null || ! PlateNumber::equals($policy->vehicle->plate_no, $plateNo)) {
            return ['result' => PolicyVerificationResult::NotFound, 'policy' => null];
        }

        return ['result' => $this->resultFor($policy), 'policy' => $policy];
    }

    private function resultFor(Policy $policy): PolicyVerificationResult
    {
        $today = CarbonImmutable::today();

        return match (true) {
            $policy->status === PolicyStatus::Expired,
            $policy->status === PolicyStatus::Active && $policy->end_date->lt($today) => PolicyVerificationResult::Expired,

            $policy->status === PolicyStatus::Active && $policy->start_date->lte($today) => PolicyVerificationResult::Valid,

            // PENDING_PAYMENT, CANCELLED, or ACTIVE with a future start date: not a valid document today.
            default => PolicyVerificationResult::NotFound,
        };
    }
}
