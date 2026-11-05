<?php

namespace Database\Seeders;

use App\Enums\UserRole;
use App\Models\User;
use Illuminate\Database\Seeder;

/**
 * One demo account per role (local/staging only). All log in via OTP;
 * with OTP_FIXED_CODE=123456 in local .env the code is always 123456.
 */
class DemoUserSeeder extends Seeder
{
    public function run(): void
    {
        $accounts = [
            ['role' => UserRole::Admin, 'name' => 'مدير النظام', 'phone' => '01000000001', 'national_id' => '29001010100011'],
            ['role' => UserRole::Surveyor, 'name' => 'أحمد المعاين', 'phone' => '01000000002', 'national_id' => '28805050100022'],
            ['role' => UserRole::Customer, 'name' => 'محمد العميل', 'phone' => '01000000003', 'national_id' => '29503030100033'],
            ['role' => UserRole::Workshop, 'name' => 'ورشة النور', 'phone' => '01000000004', 'national_id' => null],
        ];

        foreach ($accounts as $account) {
            $user = User::query()->updateOrCreate(['phone' => $account['phone']], [
                'name' => $account['name'],
                'national_id' => $account['national_id'],
                'password' => $account['role'] === UserRole::Customer ? null : 'password',
                'phone_verified_at' => now(),
                'is_active' => true,
            ]);

            $user->assignPrimaryRole($account['role']);

            if ($account['role'] === UserRole::Customer) {
                $user->vehicles()->updateOrCreate(['vin' => 'JTDBR32E720123456'], [
                    'plate_no' => 'ق ط ن 1234',
                    'make' => 'Toyota',
                    'model' => 'Corolla',
                    'year' => 2019,
                    'engine_cc' => 1600,
                ]);
            }
        }
    }
}
