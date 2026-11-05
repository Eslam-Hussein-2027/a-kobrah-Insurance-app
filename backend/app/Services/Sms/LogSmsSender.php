<?php

namespace App\Services\Sms;

use Illuminate\Support\Facades\Log;

/**
 * Development driver: writes SMS messages to the application log.
 * Replace with a real provider (e.g. Vonage, Twilio, local Egyptian gateway) via SMS_DRIVER.
 */
class LogSmsSender implements SmsSender
{
    public function send(string $phone, string $message): void
    {
        Log::info('SMS dispatched', ['phone' => $phone, 'message' => $message]);
    }
}
