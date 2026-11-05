<?php

namespace Database\Seeders;

use App\Models\CoverageType;
use Illuminate\Database\Seeder;

class CoverageTypeSeeder extends Seeder
{
    public function run(): void
    {
        CoverageType::query()->updateOrCreate(['code' => CoverageType::THIRD_PARTY], [
            'name' => 'تأمين ضد الغير (إجباري)',
            'name_en' => 'Third-Party Liability (Mandatory)',
            'description' => 'يغطي الأضرار التي تلحق بالغير (أشخاص وممتلكات) نتيجة حادث بالمركبة المؤمن عليها.',
            'base_price' => 1200.00,
            'is_mandatory' => true,
            'is_active' => true,
        ]);

        CoverageType::query()->updateOrCreate(['code' => CoverageType::COMPREHENSIVE], [
            'name' => 'تأمين شامل',
            'name_en' => 'Comprehensive',
            'description' => 'يغطي أضرار المركبة المؤمن عليها (حوادث، سرقة، حريق) بالإضافة إلى المسؤولية تجاه الغير.',
            'base_price' => 6500.00,
            'is_mandatory' => false,
            'is_active' => true,
        ]);
    }
}
