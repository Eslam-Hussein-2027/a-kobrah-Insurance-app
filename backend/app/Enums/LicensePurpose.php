<?php

namespace App\Enums;

use App\Enums\Concerns\HasLabel;

/** What the vehicle is licensed for (الغرض من الترخيص). */
enum LicensePurpose: string
{
    use HasLabel;

    case Private = 'private';
    case Taxi = 'taxi';
    case PrivateTransport = 'private_transport';
    case PublicTransport = 'public_transport';
    case PassengerTransport = 'passenger_transport';
    case DrivingSchool = 'driving_school';
    case Government = 'government';

    public static function translationGroup(): string
    {
        return 'license_purpose';
    }
}
