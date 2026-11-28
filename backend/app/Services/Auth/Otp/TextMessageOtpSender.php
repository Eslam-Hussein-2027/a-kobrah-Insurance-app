<?php

namespace App\Services\Auth\Otp;

use App\Services\Sms\SmsSender;

/**
 * Generates the code here and sends it as a text through an SmsSender
 * (the "log" driver in development and tests).
 */
final class TextMessageOtpSender implements OtpSender
{
    public function __construct(private readonly SmsSender $sms) {}

    public function send(string $phone, int $length, int $ttlMinutes): string
    {
        $code = $this->generateCode($length);

        $this->sms->send($phone, __('messages.otp.sms', ['code' => $code, 'minutes' => $ttlMinutes]));

        return $code;
    }

    private function generateCode(int $length): string
    {
        $fixed = config('insurance.otp.fixed_code');

        // Convenience for local development / mobile devs. Never honored in production.
        if (filled($fixed) && app()->environment(['local', 'testing'])) {
            return (string) $fixed;
        }

        return str_pad((string) random_int(0, (10 ** $length) - 1), $length, '0', STR_PAD_LEFT);
    }
}
