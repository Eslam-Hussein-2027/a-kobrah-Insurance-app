<?php

namespace App\Services\Pricing;

use App\Enums\TravelZone;
use App\Exceptions\BusinessRuleException;
use App\Models\TravelRate;
use Carbon\CarbonImmutable;
use Illuminate\Support\Collection;

/**
 * premium = price_per_traveller(zone, days) × travellers
 * Trip lengths are fixed options (7, 15, 30, 90 days...) defined by the active travel_rates rows.
 */
class TravelQuoteService
{
    public function quote(TravelZone $zone, int $days, int $travellers): TravelQuote
    {
        $rate = TravelRate::query()->active()->where('zone', $zone)->where('days', $days)->first();

        if ($rate === null) {
            throw new BusinessRuleException(__('messages.travel.no_rate'));
        }

        return new TravelQuote(
            rate: $rate,
            travellers: $travellers,
            premium: number_format(round((float) $rate->price * $travellers, 2, PHP_ROUND_HALF_UP), 2, '.', ''),
            currency: (string) config('insurance.currency'),
            calculatedAt: CarbonImmutable::now(),
        );
    }

    /**
     * Zones with their available trip lengths and prices, for the app's forms.
     *
     * @return list<array<string, mixed>>
     */
    public function options(): array
    {
        /** @var Collection<string, Collection<int, TravelRate>> $rates */
        $rates = TravelRate::query()->active()->orderBy('days')->get()
            ->groupBy(fn (TravelRate $rate) => $rate->zone->value);

        $zones = [];

        foreach (TravelZone::cases() as $zone) {
            $zoneRates = $rates->get($zone->value);

            if ($zoneRates === null) {
                continue;
            }

            $zones[] = [
                ...$zone->toArray(),
                'description' => $zone->description(),
                'durations' => $zoneRates->map(fn (TravelRate $rate) => [
                    'days' => $rate->days,
                    'price_per_traveller' => (string) $rate->price,
                ])->values()->all(),
            ];
        }

        return $zones;
    }
}
