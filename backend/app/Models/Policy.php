<?php

namespace App\Models;

use App\Enums\InsuranceProduct;
use App\Enums\PolicyStatus;
use App\Enums\TravelZone;
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
 * @property int $user_id
 * @property InsuranceProduct $product
 * @property int|null $vehicle_id motor only
 * @property int|null $coverage_type_id motor only
 * @property TravelZone|null $travel_zone travel only
 * @property int|null $travel_days travel only
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
        'user_id',
        'product',
        'vehicle_id',
        'coverage_type_id',
        'travel_zone',
        'travel_days',
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
            'product' => InsuranceProduct::class,
            'travel_zone' => TravelZone::class,
            'travel_days' => 'integer',
            'start_date' => 'date',
            'end_date' => 'date',
            'premium' => 'decimal:2',
            'pricing_snapshot' => 'array',
            'status' => PolicyStatus::class,
            'issued_at' => 'datetime',
        ];
    }

    // ---------------------------------------------------------------- Relations

    /** The policyholder. */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

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

    public function travellers(): HasMany
    {
        return $this->hasMany(PolicyTraveller::class);
    }

    // ---------------------------------------------------------------- Helpers

    public function isOwnedBy(User $user): bool
    {
        return $this->user_id === $user->id;
    }

    public function isTravel(): bool
    {
        return $this->product === InsuranceProduct::Travel;
    }

    /**
     * Short human name: "التأمين الإجباري (ضد الغير)" or "تأمين السفر - أوروبا (شنغن)".
     */
    public function displayName(): string
    {
        if ($this->isTravel()) {
            return $this->product->label().' - '.$this->travel_zone?->label();
        }

        return $this->coverageType?->localizedName() ?? $this->product->label();
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
