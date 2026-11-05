<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Inspection extends Model
{
    protected $fillable = [
        'claim_id',
        'surveyor_id',
        'report',
        'cost_estimate',
        'inspected_at',
    ];

    protected function casts(): array
    {
        return [
            'cost_estimate' => 'decimal:2',
            'inspected_at' => 'datetime',
        ];
    }

    public function claim(): BelongsTo
    {
        return $this->belongsTo(Claim::class);
    }

    public function surveyor(): BelongsTo
    {
        return $this->belongsTo(User::class, 'surveyor_id');
    }
}
