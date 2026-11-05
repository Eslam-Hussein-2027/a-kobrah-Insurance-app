<?php

namespace Database\Seeders;

use App\Models\CoverageType;
use Illuminate\Database\Seeder;

/**
 * The company currently sells compulsory (third-party) motor insurance only.
 * Comprehensive is kept in the catalogue but disabled, so it can be switched on later
 * (is_active = true) without code changes.
 *
 * base_price is a placeholder until the company provides its official tariff.
 */
class CoverageTypeSeeder extends Seeder
{
    public function run(): void
    {
        CoverageType::query()->updateOrCreate(['code' => CoverageType::THIRD_PARTY], [
            'name' => 'التأمين الإجباري (ضد الغير)',
            'name_en' => 'Compulsory Third-Party Insurance',
            'description' => 'يغطي الأضرار التي تسببها السيارة المؤمَّن عليها للغير (أشخاص وممتلكات).',
            'base_price' => 1200.00,
            'is_mandatory' => true,
            'is_active' => true,
        ]);

        CoverageType::query()->updateOrCreate(['code' => CoverageType::COMPREHENSIVE], [
            'name' => 'التأمين الشامل',
            'name_en' => 'Comprehensive',
            'description' => 'يغطي أضرار السيارة المؤمَّن عليها (حوادث، سرقة، حريق) بالإضافة إلى المسؤولية تجاه الغير.',
            'base_price' => 6500.00,
            'is_mandatory' => false,
            'is_active' => false,
        ]);
    }
}
