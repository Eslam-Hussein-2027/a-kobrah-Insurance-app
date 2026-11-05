<?php

namespace App\Services\Payments;

use Illuminate\Contracts\Container\Container;
use InvalidArgumentException;
use RuntimeException;

/**
 * Resolves gateways by name. Add a provider by implementing PaymentGateway and
 * registering it in GATEWAYS + config/payments.php.
 */
class PaymentGatewayManager
{
    /** @var array<string, class-string<PaymentGateway>> */
    private const GATEWAYS = [
        'simulator' => SimulatorGateway::class,
    ];

    public function __construct(private readonly Container $container) {}

    public function default(): PaymentGateway
    {
        return $this->get((string) config('payments.default'));
    }

    public function get(string $name): PaymentGateway
    {
        $class = self::GATEWAYS[$name] ?? throw new InvalidArgumentException("Unknown payment gateway [{$name}].");

        if ($name === 'simulator' && ! config('payments.gateways.simulator.enabled')) {
            throw new RuntimeException('The payment simulator is disabled in this environment.');
        }

        return $this->container->make($class);
    }

    public function has(string $name): bool
    {
        return isset(self::GATEWAYS[$name]);
    }
}
