<?php

namespace App\Services\Payments;

use App\Models\Payment;
use Illuminate\Http\Request;

/**
 * Contract for an online payment provider (hosted checkout model):
 *   1) createCheckout()  → we send the customer to the provider's payment page
 *   2) the provider calls our webhook / redirects back
 *   3) fetchStatus()     → we ask the provider for the authoritative result
 *                          (callback parameters are never trusted on their own)
 */
interface PaymentGateway
{
    /** Short identifier stored in payments.gateway (e.g. "simulator", "sadad"). */
    public function name(): string;

    public function createCheckout(Payment $payment): CheckoutSession;

    public function fetchStatus(Payment $payment): GatewayResult;

    /** Extract our payment reference from a webhook/callback request, or null if it isn't ours. */
    public function referenceFromCallback(Request $request): ?string;
}
