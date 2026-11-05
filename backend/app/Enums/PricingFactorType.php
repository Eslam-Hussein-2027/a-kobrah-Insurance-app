<?php

namespace App\Enums;

use App\Enums\Concerns\HasLabel;

enum PricingFactorType: string
{
    use HasLabel;

    /** Vehicle age in whole years (current year - manufacture year). */
    case VehicleAge = 'vehicle_age';

    /** Engine capacity in cc. */
    case EngineCc = 'engine_cc';

    /** Number of non-rejected claims by the owner within the configured look-back window. */
    case ClaimsHistory = 'claims_history';

    public static function translationGroup(): string
    {
        return 'pricing_factor_type';
    }
}
