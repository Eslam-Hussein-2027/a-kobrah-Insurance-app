<?php

namespace App\Services\Auth;

use App\Models\OtpCode;
use App\Services\Auth\Otp\OtpSender;
use Illuminate\Http\Exceptions\ThrottleRequestsException;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\RateLimiter;

class OtpService
{
    public function __construct(private readonly OtpSender $sender) {}

    /**
     * Send a new code by SMS, then keep only its hash (previous unused codes stop working).
     * SMS cost money and can be abused, so sends are limited per phone and per IP (429).
     */
    public function send(string $phone, ?string $ipAddress = null): void
    {
        $this->throttle($phone, $ipAddress);

        $code = $this->sender->send($phone, (int) config('insurance.otp.length'), $this->ttlMinutes());

        DB::transaction(function () use ($phone, $code, $ipAddress) {
            OtpCode::query()->where('phone', $phone)->whereNull('consumed_at')->delete();

            OtpCode::create([
                'phone' => $phone,
                'code_hash' => $this->hash($phone, $code),
                'expires_at' => now()->addMinutes($this->ttlMinutes()),
                'ip_address' => $ipAddress,
            ]);
        });
    }

    /**
     * Verify and consume the code. Each wrong attempt is counted; the code is locked after max attempts.
     */
    public function verify(string $phone, string $code): bool
    {
        return DB::transaction(function () use ($phone, $code): bool {
            $otp = OtpCode::query()
                ->usable($phone)
                ->latest('id')
                ->lockForUpdate()
                ->first();

            if ($otp === null || $otp->attempts >= (int) config('insurance.otp.max_attempts')) {
                return false;
            }

            if (! hash_equals($otp->code_hash, $this->hash($phone, $code))) {
                $otp->increment('attempts');

                return false;
            }

            $otp->forceFill(['consumed_at' => now()])->save();

            return true;
        });
    }

    public function resendAfterSeconds(): int
    {
        return (int) config('insurance.otp.resend_after_seconds');
    }

    private function throttle(string $phone, ?string $ipAddress): void
    {
        $limits = [
            ['otp:phone:min:'.$phone, 1, $this->resendAfterSeconds()],
            ['otp:phone:hour:'.$phone, 5, 3600],
            ['otp:ip:'.$ipAddress, 20, 3600],
        ];

        foreach ($limits as [$key, $max]) {
            if (RateLimiter::tooManyAttempts($key, $max)) {
                throw new ThrottleRequestsException(headers: ['Retry-After' => RateLimiter::availableIn($key)]);
            }
        }

        foreach ($limits as [$key, , $decaySeconds]) {
            RateLimiter::hit($key, $decaySeconds);
        }
    }

    public function ttlMinutes(): int
    {
        return (int) config('insurance.otp.ttl_minutes');
    }

    /**
     * Fast keyed hash: codes are short-lived and attempt-limited, so bcrypt is unnecessary,
     * and binding the phone prevents reusing a hash across numbers.
     */
    private function hash(string $phone, string $code): string
    {
        return hash_hmac('sha256', $phone.'|'.$code, (string) config('app.key'));
    }
}
