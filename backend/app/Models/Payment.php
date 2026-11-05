<?php

namespace App\Models;

use App\Enums\PaymentMethod;
use App\Enums\PaymentStatus;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Payment extends Model
{
    protected $fillable = [
        'policy_id',
        'amount',
        'method',
        'gateway',
        'gateway_ref',
        'checkout_url',
        'status',
        'failure_reason',
        'requires_refund',
        'gateway_payload',
        'paid_at',
        'confirmed_by',
    ];

    protected $hidden = ['gateway_payload'];

    protected function casts(): array
    {
        return [
            'amount' => 'decimal:2',
            'method' => PaymentMethod::class,
            'status' => PaymentStatus::class,
            'requires_refund' => 'boolean',
            'gateway_payload' => 'array',
            'paid_at' => 'datetime',
        ];
    }

    public function policy(): BelongsTo
    {
        return $this->belongsTo(Policy::class);
    }

    public function confirmedBy(): BelongsTo
    {
        return $this->belongsTo(User::class, 'confirmed_by');
    }
}
