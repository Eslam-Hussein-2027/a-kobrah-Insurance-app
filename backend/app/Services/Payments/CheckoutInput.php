<?php

namespace App\Services\Payments;

/**
 * What the customer chose in the app before paying (used by OTP gateways such as DPAY).
 */
final readonly class CheckoutInput
{
    public function __construct(
        /** Phone number registered with the wallet / bank app (local format 09XXXXXXXX). */
        public ?string $payerPhone = null,
        /** Gateway payment method code (e.g. "edfali"). */
        public ?string $payMethod = null,
    ) {}
}
