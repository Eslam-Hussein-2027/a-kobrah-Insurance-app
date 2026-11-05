<?php

namespace Database\Seeders;

use App\Models\Workshop;
use Illuminate\Database\Seeder;

class WorkshopSeeder extends Seeder
{
    public function run(): void
    {
        $workshops = [
            ['name' => 'مركز النور لصيانة السيارات - بنغازي', 'phone' => '0911111111', 'lat' => 32.1166700, 'lng' => 20.0666700, 'is_approved' => true],
            ['name' => 'ورشة الأمل - طرابلس', 'phone' => '0922222222', 'lat' => 32.8872000, 'lng' => 13.1913000, 'is_approved' => true],
            ['name' => 'ورشة مصراتة الحديثة', 'phone' => '0943333333', 'lat' => 32.3754000, 'lng' => 15.0925000, 'is_approved' => false],
        ];

        foreach ($workshops as $workshop) {
            Workshop::query()->updateOrCreate(['name' => $workshop['name']], $workshop);
        }
    }
}
