<?php

namespace App\Models;

use App\Enums\UserDocumentType;
use App\Enums\UserRole;
use Database\Factories\UserFactory;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasManyThrough;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;
use Spatie\Permission\Traits\HasRoles;

/**
 * @property int $id
 * @property string $name
 * @property string $phone
 * @property string|null $national_id
 * @property UserRole $role
 * @property string|null $id_image
 * @property string|null $license_image
 * @property bool $is_active
 */
class User extends Authenticatable
{
    /** @use HasFactory<UserFactory> */
    use HasApiTokens, HasFactory, HasRoles, Notifiable;

    protected $fillable = [
        'name',
        'phone',
        'national_id',
        'password',
        'phone_verified_at',
        'is_active',
    ];

    protected $hidden = [
        'password',
        'remember_token',
        'id_image',
        'license_image',
    ];

    protected function casts(): array
    {
        return [
            'password' => 'hashed',
            'role' => UserRole::class,
            'is_active' => 'boolean',
            'phone_verified_at' => 'datetime',
        ];
    }

    // ---------------------------------------------------------------- Relations

    public function vehicles(): HasMany
    {
        return $this->hasMany(Vehicle::class);
    }

    public function policies(): HasManyThrough
    {
        return $this->hasManyThrough(Policy::class, Vehicle::class);
    }

    /** Inspections assigned to this user as a surveyor. */
    public function inspections(): HasMany
    {
        return $this->hasMany(Inspection::class, 'surveyor_id');
    }

    public function notificationLogs(): HasMany
    {
        return $this->hasMany(NotificationLog::class);
    }

    // ---------------------------------------------------------------- Roles

    /**
     * Single entry point for changing a user's role: keeps the `role` column
     * and the spatie role assignment in sync.
     */
    public function assignPrimaryRole(UserRole $role): static
    {
        $this->forceFill(['role' => $role])->save();
        $this->syncRoles([$role->value]);

        return $this;
    }

    public function isAdmin(): bool
    {
        return $this->role === UserRole::Admin;
    }

    public function isCustomer(): bool
    {
        return $this->role === UserRole::Customer;
    }

    // ---------------------------------------------------------------- KYC documents

    public function documentPath(UserDocumentType $type): ?string
    {
        return $this->getAttribute($type->value);
    }

    public function hasKycDocuments(): bool
    {
        return filled($this->id_image) && filled($this->license_image);
    }
}
