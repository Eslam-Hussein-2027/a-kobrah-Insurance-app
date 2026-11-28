<?php

namespace App\Enums;

use App\Enums\Concerns\HasLabel;

/** Body colour as written on the vehicle registration. */
enum VehicleColor: string
{
    use HasLabel;

    case White = 'white';
    case Black = 'black';
    case Silver = 'silver';
    case Grey = 'grey';
    case Red = 'red';
    case Blue = 'blue';
    case Green = 'green';
    case Beige = 'beige';
    case Brown = 'brown';
    case Gold = 'gold';
    case Yellow = 'yellow';
    case Orange = 'orange';
    case Other = 'other';

    public static function translationGroup(): string
    {
        return 'vehicle_color';
    }
}
