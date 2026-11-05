<?php

namespace App\Services\Payments;

final readonly class GatewayResult
{
    public const PENDING = 'pending';

    public const PAID = 'paid';

    public const FAILED = 'failed';

    /**
     * @param  array<string, mixed>  $payload  raw provider response, kept for audit
     */
    public function __construct(
        public string $status,
        public ?string $amount = null,
        public ?string $reason = null,
        public array $payload = [],
    ) {}

    public static function pending(array $payload = []): self
    {
        return new self(self::PENDING, payload: $payload);
    }

    public static function paid(string $amount, array $payload = []): self
    {
        return new self(self::PAID, amount: $amount, payload: $payload);
    }

    public static function failed(string $reason, array $payload = []): self
    {
        return new self(self::FAILED, reason: $reason, payload: $payload);
    }
}
