<?php

namespace App\Services\Admin;

use App\Enums\PricingFactorType;
use App\Exceptions\BusinessRuleException;
use App\Models\PricingFactor;

/**
 * Admin-side management of pricing bands. Bands of the same type must not overlap, and
 * gaps are reported so the dashboard can warn before customers hit "no pricing factor" errors.
 */
class PricingFactorService
{
    /**
     * @param  array{factor_type: string, min_value: int, max_value: ?int, multiplier: numeric}  $data
     */
    public function save(array $data, ?PricingFactor $factor = null): PricingFactor
    {
        $type = PricingFactorType::from($data['factor_type']);
        $min = (int) $data['min_value'];
        $max = $data['max_value'] === null ? null : (int) $data['max_value'];

        $overlapping = PricingFactor::query()
            ->ofType($type)
            ->when($factor, fn ($q) => $q->whereKeyNot($factor->id))
            ->get()
            ->first(fn (PricingFactor $other) => $min <= ($other->max_value ?? PHP_INT_MAX)
                && $other->min_value <= ($max ?? PHP_INT_MAX));

        if ($overlapping !== null) {
            throw new BusinessRuleException(__('messages.pricing.overlap', [
                'min' => $overlapping->min_value,
                'max' => $overlapping->max_value ?? '∞',
            ]));
        }

        $factor ??= new PricingFactor;
        $factor->fill(['factor_type' => $type, 'min_value' => $min, 'max_value' => $max, 'multiplier' => $data['multiplier']])->save();

        return $factor;
    }

    /**
     * Human-readable gaps per factor type, e.g. ["engine_cc" => ["1301 - 1599"], "claims_history" => ["≥ 3"]].
     *
     * @return array<string, list<string>>
     */
    public function gaps(): array
    {
        $gaps = [];

        foreach (PricingFactorType::cases() as $type) {
            $bands = PricingFactor::query()->ofType($type)->orderBy('min_value')->get();
            $missing = [];
            $expected = 0;

            foreach ($bands as $band) {
                if ($band->min_value > $expected) {
                    $missing[] = $expected.' - '.($band->min_value - 1);
                }
                if ($band->max_value === null) {
                    $expected = null;
                    break;
                }
                $expected = max($expected, $band->max_value + 1);
            }

            if ($expected !== null) {
                $missing[] = '≥ '.$expected;
            }

            $gaps[$type->value] = $missing;
        }

        return $gaps;
    }
}
