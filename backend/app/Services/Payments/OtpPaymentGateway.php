<?php

namespace App\Services\Payments;

use App\Exceptions\BusinessRuleException;
use App\Models\Payment;

/**
 * Providers where the customer confirms the payment with a code they receive by SMS,
 * typed in our app (no hosted payment page).
 */
interface OtpPaymentGateway extends PaymentGateway
{
    /**
     * Payment methods the customer can choose from (codes from config/payments.php → methods).
     *
     * @return list<string>
     */
    public function payMethods(): array;

    /**
     * Send the customer's code to the provider, then return the provider's authoritative status.
     *
     * @throws BusinessRuleException when the code is rejected and the session is still open
     */
    public function confirmOtp(Payment $payment, string $otp): GatewayResult;
}
