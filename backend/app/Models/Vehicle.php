<?php

namespace App\Models;

use App\Enums\LicensePurpose;
use App\Enums\LicensingAuthority;
use App\Enums\ManufactureCountry;
use App\Enums\PolicyStatus;
use App\Enums\VehicleColor;
use Database\Factories\VehicleFactory;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

/**
 * @property int $id
 * @property int $user_id
 * @property string|null $owner_name
 * @property string|null $owner_address
 * @property string $plate_no
 * @property string $vin
 * @property string $make
 * @property string $model
 * @property int $year
 * @property int $engine_cc
 * @property VehicleColor|null $color
 * @property ManufactureCountry|null $country_of_origin
 * @property LicensePurpose|null $license_purpose
 * @property int|null $seats
 * @property LicensingAuthority|null $licensing_authority
 */
class Vehicle extends Model
{
    /** @use HasFactory<VehicleFactory> */
    use HasFactory;

    protected $fillable = [
        'owner_name',
        'owner_address',
        'plate_no',
        'vin',
        'make',
        'model',
        'year',
        'engine_cc',
        'color',
        'country_of_origin',
        'license_purpose',
        'seats',
        'licensing_authority',
    ];

    /** Filled for every vehicle added from now on; older ones are completed before a new policy. */
    public const REGISTRATION_DETAILS = [
        'owner_name', 'owner_address', 'color', 'country_of_origin', 'license_purpose', 'seats', 'licensing_authority',
    ];

    protected function casts(): array
    {
        return [
            'year' => 'integer',
            'engine_cc' => 'integer',
            'color' => VehicleColor::class,
            'country_of_origin' => ManufactureCountry::class,
            'license_purpose' => LicensePurpose::class,
            'seats' => 'integer',
            'licensing_authority' => LicensingAuthority::class,
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function policies(): HasMany
    {
        return $this->hasMany(Policy::class);
    }

    public function hasRegistrationDetails(): bool
    {
        return collect(self::REGISTRATION_DETAILS)->every(fn (string $field) => filled($this->{$field}));
    }

    public function ageInYears(): int
    {
        return self::ageForYear($this->year);
    }

    public static function ageForYear(int $manufactureYear): int
    {
        return max(0, (int) now()->year - $manufactureYear);
    }

    /** True when the vehicle has a policy that is awaiting payment or in force. */
    public function hasBlockingPolicy(): bool
    {
        return $this->policies()->whereIn('status', PolicyStatus::blocking())->exists();
    }
}
