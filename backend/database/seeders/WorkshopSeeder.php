<?php

namespace Database\Seeders;

use App\Models\Workshop;
use Illuminate\Database\Seeder;

class WorkshopSeeder extends Seeder
{
    public function run(): void
    {
        $workshops = [
            ['name' => 'مركز النور لصيانة السيارات', 'phone' => '0223456789', 'lat' => 30.0444196, 'lng' => 31.2357116, 'is_approved' => true],
            ['name' => 'ورشة الأمل - مدينة نصر', 'phone' => '0222876543', 'lat' => 30.0561000, 'lng' => 31.3301000, 'is_approved' => true],
            ['name' => 'ورشة الإسكندرية الحديثة', 'phone' => '034567890', 'lat' => 31.2000924, 'lng' => 29.9187387, 'is_approved' => false],
        ];

        foreach ($workshops as $workshop) {
            Workshop::query()->updateOrCreate(['name' => $workshop['name']], $workshop);
        }
    }
}
