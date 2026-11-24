<?php

namespace App\Services\Policy;

use App\Enums\PolicyStatus;
use App\Enums\PolicyVerificationResult;
use App\Models\Policy;
use App\Support\PlateNumber;
use Carbon\CarbonImmutable;

/**
 * Public verification for police, government bodies, companies and other drivers.
 *
 * Two entry points:
 *  - policy_no + plate_no (typed by hand, app/API/web form): validity only, no personal data.
 *  - the QR code printed on the policy: /verify/{policy_no}/{token}. The token is an HMAC of the
 *    policy number, so a QR cannot be forged for a made-up number; a copied QR shows the real
 *    vehicle, which the inspector compares with the car in front of them.
 */
class PolicyVerificationService
{
    /** Public status shown on the verification page (more precise than the 3-value API result). */
    public const VALID = 'valid';

    public const EXPIRED = 'expired';

    public const CANCELLED = 'cancelled';

    public const NOT_ACTIVE = 'not_active';

    private const TOKEN_LENGTH = 20;

    /**
     * @return array{result: PolicyVerificationResult, policy: ?Policy}
     */
    public function verify(string $policyNo, string $plateNo): array
    {
        $policy = $this->findByPlate($policyNo, $plateNo);

        if ($policy === null) {
            return ['result' => PolicyVerificationResult::NotFound, 'policy' => null];
        }

        return ['result' => $this->resultFor($policy), 'policy' => $policy];
    }

    /** Policy matching both the number and the plate (any status), or null. */
    public function findByPlate(string $policyNo, string $plateNo): ?Policy
    {
        $policy = $this->find($policyNo);

        // Typed verification is for motor policies (travel policies are checked through their QR code).
        return $policy?->vehicle !== null && PlateNumber::equals($policy->vehicle->plate_no, $plateNo) ? $policy : null;
    }

    /** Policy referenced by a QR link, or null when the number is unknown or the token is wrong. */
    public function findByToken(string $policyNo, string $token): ?Policy
    {
        $policy = $this->find($policyNo);

        return $policy !== null && hash_equals($this->token($policy), $token) ? $policy : null;
    }

    public function token(Policy $policy): string
    {
        return substr(hash_hmac('sha256', 'policy-verification|'.$policy->policy_no, $this->secret()), 0, self::TOKEN_LENGTH);
    }

    /** The URL encoded in the QR code. */
    public function url(Policy $policy): string
    {
        return rtrim((string) config('insurance.company.verification_url'), '/').'/'.$policy->policy_no.'/'.$this->token($policy);
    }

    public function publicStatus(Policy $policy): string
    {
        $today = CarbonImmutable::today();

        return match (true) {
            $policy->status === PolicyStatus::Cancelled => self::CANCELLED,
            $policy->status === PolicyStatus::Expired,
            $policy->status === PolicyStatus::Active && $policy->end_date->lt($today) => self::EXPIRED,
            $policy->status === PolicyStatus::Active && $policy->start_date->lte($today) => self::VALID,
            default => self::NOT_ACTIVE, // awaiting payment, or coverage starts later
        };
    }

    private function resultFor(Policy $policy): PolicyVerificationResult
    {
        return match ($this->publicStatus($policy)) {
            self::VALID => PolicyVerificationResult::Valid,
            self::EXPIRED => PolicyVerificationResult::Expired,
            // Pending payment, cancelled or not yet started: not a valid document today.
            default => PolicyVerificationResult::NotFound,
        };
    }

    private function find(string $policyNo): ?Policy
    {
        return Policy::query()
            ->with(['user', 'vehicle', 'coverageType', 'travellers'])
            ->where('policy_no', strtoupper(trim($policyNo)))
            ->first();
    }

    /**
     * Dedicated secret so rotating APP_KEY does not invalidate a year of printed policies.
     */
    private function secret(): string
    {
        return (string) (config('insurance.verification_secret') ?: config('app.key'));
    }
}
