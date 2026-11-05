<?php

namespace App\Models;

use App\Enums\ClaimStatus;
use Database\Factories\ClaimFactory;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Claim extends Model
{
    /** @use HasFactory<ClaimFactory> */
    use HasFactory;

    protected $fillable = [
        'claim_no',
        'policy_id',
        'incident_date',
        'lat',
        'lng',
        'description',
        'other_party_name',
        'other_party_plate',
        'other_party_policy_id',
        'status',
        'estimated_cost',
        'approved_amount',
        'rejection_reason',
    ];

    protected function casts(): array
    {
        return [
            'incident_date' => 'datetime',
            'lat' => 'decimal:7',
            'lng' => 'decimal:7',
            'status' => ClaimStatus::class,
            'estimated_cost' => 'decimal:2',
            'approved_amount' => 'decimal:2',
        ];
    }

    public function policy(): BelongsTo
    {
        return $this->belongsTo(Policy::class);
    }

    public function otherPartyPolicy(): BelongsTo
    {
        return $this->belongsTo(Policy::class, 'other_party_policy_id');
    }

    public function media(): HasMany
    {
        return $this->hasMany(ClaimMedia::class);
    }

    public function inspections(): HasMany
    {
        return $this->hasMany(Inspection::class);
    }

    public function statusLogs(): HasMany
    {
        return $this->hasMany(ClaimStatusLog::class)->orderBy('created_at');
    }
}
