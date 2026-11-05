<?php

namespace Database\Seeders;

use App\Enums\UserRole;
use Illuminate\Database\Seeder;
use Spatie\Permission\Models\Permission;
use Spatie\Permission\Models\Role;
use Spatie\Permission\PermissionRegistrar;

class RolesAndPermissionsSeeder extends Seeder
{
    /**
     * Fine-grained permissions for the admin dashboard (phase 3). Roles are the coarse gate today.
     *
     * @var array<string, list<string>>
     */
    private const MATRIX = [
        'customer' => [
            'vehicles.manage-own',
            'policies.buy',
            'claims.submit',
        ],
        'surveyor' => [
            'claims.view-assigned',
            'inspections.submit',
        ],
        'workshop' => [
            'repairs.update-status',
        ],
        'admin' => [
            'pricing.manage',
            'policies.manage',
            'payments.confirm',
            'claims.manage',
            'claims.assign-surveyor',
            'users.manage',
            'workshops.manage',
            'reports.view',
        ],
    ];

    public function run(): void
    {
        app(PermissionRegistrar::class)->forgetCachedPermissions();

        foreach (UserRole::cases() as $roleEnum) {
            $role = Role::findOrCreate($roleEnum->value, 'web');

            $permissions = collect(self::MATRIX[$roleEnum->value] ?? [])
                ->map(fn (string $name) => Permission::findOrCreate($name, 'web'));

            $role->syncPermissions($permissions);
        }

        app(PermissionRegistrar::class)->forgetCachedPermissions();
    }
}
