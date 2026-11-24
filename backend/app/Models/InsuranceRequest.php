<?php

namespace App\Models;

use App\Enums\InsuranceProduct;
use App\Enums\InsuranceRequestKind;
use App\Enums\InsuranceRequestStatus;
use Carbon\CarbonImmutable;
use Database\Factories\InsuranceRequestFactory;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

/**
 * A customer's request for a product that staff price and issue manually.
 *
 * @property int $id
 * @property string $request_no
 * @property int $user_id
 * @property InsuranceProduct $product
 * @property InsuranceRequestKind $kind
 * @property InsuranceRequestStatus $status
 * @property array<string, mixed> $details
 * @property string|null $notes
 * @property string|null $staff_reply
 * @property string|null $quoted_amount
 * @property int|null $handled_by
 * @property CarbonImmutable|null $replied_at
 */
class InsuranceRequest extends Model
{
    /** @use HasFactory<InsuranceRequestFactory> */
    use HasFactory;

    protected $fillable = [
        'request_no',
        'product',
        'kind',
        'status',
        'details',
        'notes',
        'staff_reply',
        'quoted_amount',
        'handled_by',
        'replied_at',
    ];

    protected function casts(): array
    {
        return [
            'product' => InsuranceProduct::class,
            'kind' => InsuranceRequestKind::class,
            'status' => InsuranceRequestStatus::class,
            'details' => 'array',
            'quoted_amount' => 'decimal:2',
            'replied_at' => 'datetime',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function handler(): BelongsTo
    {
        return $this->belongsTo(User::class, 'handled_by');
    }

    public function documents(): HasMany
    {
        return $this->hasMany(InsuranceRequestDocument::class);
    }
}
