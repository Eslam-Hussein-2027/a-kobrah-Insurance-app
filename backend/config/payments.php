<?php

/*
|--------------------------------------------------------------------------
| Online payments
|--------------------------------------------------------------------------
| Every provider implements App\Services\Payments\PaymentGateway.
| "simulator" is a built-in fake gateway for development and demos: it must never
| be enabled in production (it would let anyone mark a payment as paid).
*/

return [

    'default' => env('PAYMENT_GATEWAY', 'simulator'),

    'gateways' => [
        'simulator' => [
            'enabled' => (bool) env('PAYMENT_SIMULATOR_ENABLED', env('APP_ENV') !== 'production'),
        ],
        // DPAY (dpay.ly): one API for Libyan wallets and bank apps. The customer enters their phone
        // number in our app, the provider sends them a code, and they confirm it in our app (OTP flow).
        'dpay' => [
            'base_url' => env('DPAY_BASE_URL', 'https://dpay.ly'),
            // Test tokens (sb_tk_...) only work on /api/sandbox/..., live tokens only on the live paths.
            'sandbox' => (bool) env('DPAY_SANDBOX', true),
            'api_prefix' => env('DPAY_API_PREFIX'), // override; default /api/sandbox or /api
            'token' => env('DPAY_API_TOKEN'),
            // Signs every webhook (header X-Dpay-Signature = hex HMAC-SHA256 of the raw body).
            'webhook_secret' => env('DPAY_WEBHOOK_SECRET'),
            // Methods connected in the DPAY dashboard (Payment methods page), comma separated.
            'pay_methods' => array_values(array_filter(array_map('trim', explode(',', (string) env('DPAY_PAY_METHODS', 'edfali'))))),
            'timeout_seconds' => (int) env('DPAY_TIMEOUT_SECONDS', 20),
        ],
    ],

    /*
    | Payment methods offered through the gateway: dpay code => limits (LYD) shown in its dashboard.
    | Labels are translated in lang/{locale}/payments.php.
    */
    'methods' => [
        'edfali' => ['min' => 5, 'max' => 60000],
        'mobicash' => ['min' => 5, 'max' => 60000],
        'moamalat' => ['min' => 5, 'max' => 60000],
        'sadad' => ['min' => 1, 'max' => 5000],
        'yousrpay' => ['min' => 5, 'max' => 60000],
        'masrefypay' => ['min' => 5, 'max' => 60000],
        'saharapay' => ['min' => 5, 'max' => 60000],
        'mpgs' => ['min' => 1, 'max' => 10000],
    ],

    // Minutes a checkout link stays valid.
    'checkout_ttl_minutes' => (int) env('PAYMENT_CHECKOUT_TTL_MINUTES', 30),

];
