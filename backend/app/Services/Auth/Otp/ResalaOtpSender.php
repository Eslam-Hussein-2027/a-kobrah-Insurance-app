<?php

namespace App\Services\Auth\Otp;

use App\Exceptions\BusinessRuleException;
use App\Services\Sms\Resala\ResalaClient;
use App\Services\Sms\Resala\ResalaErrorType;
use App\Services\Sms\Resala\ResalaException;
use Illuminate\Support\Facades\Log;
use Illuminate\Validation\ValidationException;

/**
 * Codes generated and texted by Resala (POST /pins).
 * A number Resala cannot text is a form error on "phone"; anything else is logged for the
 * company (top up, renew, new key...) and the customer is asked to try again later.
 */
final class ResalaOtpSender implements OtpSender
{
    public function __construct(private readonly ResalaClient $resala) {}

    public function send(string $phone, int $length, int $ttlMinutes): string
    {
        try {
            $pin = $this->resala->sendPin($phone, $length);
        } catch (ResalaException $exception) {
            throw $this->userError($exception);
        }

        if ($this->resala->isTestMode()) {
            // Test mode sends nothing; the code is only here, for the developer.
            Log::info('Resala test mode: SMS not sent', ['phone' => $phone, 'pin' => $pin->pin]);
        }

        return $pin->pin;
    }

    private function userError(ResalaException $exception): ValidationException|BusinessRuleException
    {
        if ($exception->type === ResalaErrorType::InputValidation) {
            return ValidationException::withMessages(['phone' => __('messages.otp.number_not_supported')]);
        }

        $context = ['type' => $exception->type->value, 'status' => $exception->status, 'message' => $exception->getMessage()];
        $exception->type->needsAttention()
            ? Log::critical('Resala: verification SMS not sent, the Resala account needs attention', $context)
            : Log::error('Resala: verification SMS not sent', $context);

        return new BusinessRuleException(__('messages.otp.unavailable'), 503);
    }
}
