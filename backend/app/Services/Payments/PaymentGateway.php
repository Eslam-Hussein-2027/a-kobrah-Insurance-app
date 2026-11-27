<?php

namespace App\Services\Payments;

use App\Models\Payment;
use Illuminate\Http\Request;

/**
 * Contract for an online payment provider:
 *   1) createCheckout()  → hosted page (redirect) or a code sent to the customer (OtpPaymentGateway)
 *   2) the provider calls our webhook / redirects back
 *   3) fetchStatus()     → we ask the provider for the authoritative result
 *                          (callback parameters are never trusted on their own)
 */
interface PaymentGateway
{
    /** Short identifier stored in payments.gateway (e.g. "simulator", "dpay"). */
    public function name(): string;

    public function createCheckout(Payment $payment, CheckoutInput $input): CheckoutSession;

    public function fetchStatus(Payment $payment): GatewayResult;

    /** Extract our payment reference from a webhook/callback request, or null if it isn't ours (or isn't authentic). */
    public function referenceFromCallback(Request $request): ?string;
}
