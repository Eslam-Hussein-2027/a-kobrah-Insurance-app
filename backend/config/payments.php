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
        // 'sadad' => ['api_key' => env('SADAD_API_KEY'), ...],  ← added when a provider is chosen
    ],

    // Minutes a checkout link stays valid.
    'checkout_ttl_minutes' => (int) env('PAYMENT_CHECKOUT_TTL_MINUTES', 30),

];
