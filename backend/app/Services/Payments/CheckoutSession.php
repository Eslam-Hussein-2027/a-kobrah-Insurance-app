<?php

namespace App\Services\Payments;

final readonly class CheckoutSession
{
    public function __construct(
        /** Provider transaction id, stored in payments.gateway_ref. */
        public string $reference,
        /** Where the customer completes the payment. */
        public string $redirectUrl,
    ) {}
}
