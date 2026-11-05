<?php

namespace App\Services\Auth;

use App\Models\OtpCode;
use App\Services\Sms\SmsSender;
use Illuminate\Support\Facades\DB;

class OtpService
{
    public function __construct(private readonly SmsSender $sms) {}

    /**
     * Issue a new code for the phone (invalidating previous unused codes) and send it by SMS.
     */
    public function send(string $phone, ?string $ipAddress = null): void
    {
        $code = $this->generateCode();

        DB::transaction(function () use ($phone, $code, $ipAddress) {
            OtpCode::query()->where('phone', $phone)->whereNull('consumed_at')->delete();

            OtpCode::create([
                'phone' => $phone,
                'code_hash' => $this->hash($phone, $code),
                'expires_at' => now()->addMinutes($this->ttlMinutes()),
                'ip_address' => $ipAddress,
            ]);
        });

        $this->sms->send($phone, __('messages.otp.sms', [
            'code' => $code,
            'minutes' => $this->ttlMinutes(),
        ]));
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

    public function ttlMinutes(): int
    {
        return (int) config('insurance.otp.ttl_minutes');
    }

    private function generateCode(): string
    {
        $length = (int) config('insurance.otp.length');
        $fixed = config('insurance.otp.fixed_code');

        // Convenience for local development / mobile devs. Never honored in production.
        if (filled($fixed) && app()->environment(['local', 'testing'])) {
            return (string) $fixed;
        }

        return str_pad((string) random_int(0, (10 ** $length) - 1), $length, '0', STR_PAD_LEFT);
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
