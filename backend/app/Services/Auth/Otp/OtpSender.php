<?php

namespace App\Services\Auth\Otp;

/**
 * Delivers a verification code by SMS and returns the code that was sent
 * (some providers, like Resala, generate the code themselves).
 */
interface OtpSender
{
    public function send(string $phone, int $length, int $ttlMinutes): string;
}
