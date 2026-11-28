<?php

/*
|--------------------------------------------------------------------------
| Vehicle form
|--------------------------------------------------------------------------
| makes  brands offered in the app's "vehicle type" list, stored as written here (Latin) and shown
|        with their Arabic name from lang/ar/vehicles.php. Customers can still type a brand that
|        is not listed.
| seats  allowed passenger count (عدد الركاب).
|
| Colour, country of manufacture, licence purpose and licensing authority are enums
| (App\Enums\VehicleColor, ManufactureCountry, LicensePurpose, LicensingAuthority).
*/

return [

    'makes' => [
        'Toyota', 'Hyundai', 'Kia', 'Nissan', 'Mitsubishi', 'Honda', 'Mazda', 'Suzuki', 'Isuzu', 'Lexus',
        'Infiniti', 'Subaru', 'Chevrolet', 'Ford', 'GMC', 'Jeep', 'Dodge', 'Mercedes-Benz', 'BMW', 'Audi',
        'Volkswagen', 'Opel', 'Peugeot', 'Renault', 'Citroen', 'Fiat', 'Skoda', 'Volvo', 'Land Rover',
        'Chery', 'Geely', 'Great Wall', 'Haval', 'Changan', 'JAC', 'BYD', 'MG', 'Daewoo', 'SsangYong',
        'Proton', 'Dacia', 'Iveco', 'MAN', 'Scania', 'DAF', 'Hino', 'Tata',
    ],

    'seats' => ['min' => 1, 'max' => 60],

];
