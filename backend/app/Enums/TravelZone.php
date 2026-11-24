<?php

namespace App\Enums;

use App\Enums\Concerns\HasLabel;

enum TravelZone: string
{
    use HasLabel;

    case Arab = 'arab';
    case Schengen = 'schengen';
    case Worldwide = 'worldwide';

    public static function translationGroup(): string
    {
        return 'travel_zone';
    }

    public function description(): string
    {
        return __('travel.zones.'.$this->value);
    }
}
