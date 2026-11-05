<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        // Reference data — safe for every environment (idempotent).
        $this->call([
            RolesAndPermissionsSeeder::class,
            CoverageTypeSeeder::class,
            PricingFactorSeeder::class,
        ]);

        // Demo data — never in production.
        if (! app()->isProduction()) {
            $this->call([
                DemoUserSeeder::class,
                WorkshopSeeder::class,
            ]);
        }
    }
}
