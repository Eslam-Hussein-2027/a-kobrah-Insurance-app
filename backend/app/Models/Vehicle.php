<?php

namespace App\Models;

use App\Enums\PolicyStatus;
use Database\Factories\VehicleFactory;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

/**
 * @property int $id
 * @property int $user_id
 * @property string $plate_no
 * @property string $vin
 * @property string $make
 * @property string $model
 * @property int $year
 * @property int $engine_cc
 */
class Vehicle extends Model
{
    /** @use HasFactory<VehicleFactory> */
    use HasFactory;

    protected $fillable = [
        'plate_no',
        'vin',
        'make',
        'model',
        'year',
        'engine_cc',
    ];

    protected function casts(): array
    {
        return [
            'year' => 'integer',
            'engine_cc' => 'integer',
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

    public function ageInYears(): int
    {
        return max(0, (int) now()->year - $this->year);
    }

    /** True when the vehicle has a policy that is awaiting payment or in force. */
    public function hasBlockingPolicy(): bool
    {
        return $this->policies()->whereIn('status', PolicyStatus::blocking())->exists();
    }
}
