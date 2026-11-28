<?php

namespace App\Enums;

use App\Enums\Concerns\HasLabel;

/** Country of manufacture (بلد الصنع). */
enum ManufactureCountry: string
{
    use HasLabel;

    case Japan = 'japan';
    case SouthKorea = 'south_korea';
    case Germany = 'germany';
    case UnitedStates = 'united_states';
    case China = 'china';
    case France = 'france';
    case Italy = 'italy';
    case UnitedKingdom = 'united_kingdom';
    case Sweden = 'sweden';
    case CzechRepublic = 'czech_republic';
    case Spain = 'spain';
    case Turkey = 'turkey';
    case India = 'india';
    case Iran = 'iran';
    case Malaysia = 'malaysia';
    case Other = 'other';

    public static function translationGroup(): string
    {
        return 'manufacture_country';
    }
}
