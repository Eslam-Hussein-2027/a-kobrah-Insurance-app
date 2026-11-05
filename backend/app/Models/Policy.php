<?php

namespace App\Models;

use App\Enums\PolicyStatus;
use Carbon\CarbonImmutable;
use Database\Factories\PolicyFactory;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;

/**
 * An insurance policy (not to be confused with Laravel authorization policies).
 *
 * @property int $id
 * @property string $policy_no
 * @property int $vehicle_id
 * @property int $coverage_type_id
 * @property int|null $previous_policy_id
 * @property CarbonImmutable $start_date
 * @property CarbonImmutable $end_date
 * @property string $premium
 * @property array|null $pricing_snapshot
 * @property PolicyStatus $status
 * @property string|null $pdf_path
 * @property CarbonImmutable|null $issued_at
 */
class Policy extends Model
{
    /** @use HasFactory<PolicyFactory> */
    use HasFactory;

    protected $fillable = [
        'policy_no',
        'vehicle_id',
        'coverage_type_id',
        'previous_policy_id',
        'start_date',
        'end_date',
        'premium',
        'pricing_snapshot',
        'status',
        'pdf_path',
        'issued_at',
    ];

    protected function casts(): array
    {
        return [
            'start_date' => 'date',
            'end_date' => 'date',
            'premium' => 'decimal:2',
            'pricing_snapshot' => 'array',
            'status' => PolicyStatus::class,
            'issued_at' => 'datetime',
        ];
    }

    // ---------------------------------------------------------------- Relations

    public function vehicle(): BelongsTo
    {
        return $this->belongsTo(Vehicle::class);
    }

    public function coverageType(): BelongsTo
    {
        return $this->belongsTo(CoverageType::class);
    }

    public function previousPolicy(): BelongsTo
    {
        return $this->belongsTo(self::class, 'previous_policy_id');
    }

    /** The policy that renewed this one (if any). */
    public function renewal(): HasOne
    {
        return $this->hasOne(self::class, 'previous_policy_id');
    }

    public function payments(): HasMany
    {
        return $this->hasMany(Payment::class);
    }

    public function claims(): HasMany
    {
        return $this->hasMany(Claim::class);
    }

    // ---------------------------------------------------------------- Helpers

    public function isOwnedBy(User $user): bool
    {
        return $this->vehicle()->where('user_id', $user->id)->exists();
    }

    public function isActive(): bool
    {
        return $this->status === PolicyStatus::Active;
    }

    public function isPendingPayment(): bool
    {
        return $this->status === PolicyStatus::PendingPayment;
    }
}
