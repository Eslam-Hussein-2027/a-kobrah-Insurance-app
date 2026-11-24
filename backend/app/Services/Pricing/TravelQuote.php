<?php

namespace App\Services\Pricing;

use App\Enums\TravelZone;
use App\Models\TravelRate;
use Carbon\CarbonImmutable;

/**
 * Immutable travel price: per-traveller rate × number of travellers.
 */
final readonly class TravelQuote
{
    public function __construct(
        public TravelRate $rate,
        public int $travellers,
        public string $premium,
        public string $currency,
        public CarbonImmutable $calculatedAt,
    ) {}

    public function zone(): TravelZone
    {
        return $this->rate->zone;
    }

    public function days(): int
    {
        return $this->rate->days;
    }

    /**
     * Persisted on the policy for audit (rates are admin-editable).
     *
     * @return array<string, mixed>
     */
    public function snapshot(): array
    {
        return [
            'product' => 'travel',
            'zone' => $this->rate->zone->value,
            'days' => $this->rate->days,
            'rate_id' => $this->rate->id,
            'price_per_traveller' => (string) $this->rate->price,
            'travellers' => $this->travellers,
            'premium' => $this->premium,
            'currency' => $this->currency,
            'calculated_at' => $this->calculatedAt->toIso8601String(),
        ];
    }

    /**
     * @return array<string, mixed>
     */
    public function toArray(): array
    {
        return [
            'zone' => $this->rate->zone->toArray(),
            'days' => $this->rate->days,
            'price_per_traveller' => (string) $this->rate->price,
            'travellers' => $this->travellers,
            'premium' => $this->premium,
            'currency' => $this->currency,
        ];
    }
}
