<?php

namespace App\Models;

use App\Enums\ClaimStatus;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

/**
 * Append-only audit trail of claim status changes.
 */
class ClaimStatusLog extends Model
{
    public const UPDATED_AT = null;

    protected $fillable = [
        'claim_id',
        'from_status',
        'to_status',
        'changed_by',
        'note',
    ];

    protected function casts(): array
    {
        return [
            'from_status' => ClaimStatus::class,
            'to_status' => ClaimStatus::class,
        ];
    }

    public function claim(): BelongsTo
    {
        return $this->belongsTo(Claim::class);
    }

    public function changedBy(): BelongsTo
    {
        return $this->belongsTo(User::class, 'changed_by');
    }
}
