<?php

namespace App\Services\Payments;

final readonly class CheckoutSession
{
    public function __construct(
        /** Provider transaction id, stored in payments.gateway_ref. */
        public string $reference,
        /** Hosted payment page, or null when the customer confirms with a code in our app. */
        public ?string $redirectUrl = null,
        /** True when the provider sent the customer a code to confirm (see OtpPaymentGateway). */
        public bool $requiresOtp = false,
    ) {}
}
