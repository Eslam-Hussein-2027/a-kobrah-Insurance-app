<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Model;

class OtpCode extends Model
{
    protected $fillable = [
        'phone',
        'code_hash',
        'attempts',
        'expires_at',
        'consumed_at',
        'ip_address',
    ];

    protected $hidden = ['code_hash'];

    protected function casts(): array
    {
        return [
            'attempts' => 'integer',
            'expires_at' => 'datetime',
            'consumed_at' => 'datetime',
        ];
    }

    public function scopeUsable(Builder $query, string $phone): Builder
    {
        return $query->where('phone', $phone)
            ->whereNull('consumed_at')
            ->where('expires_at', '>', now());
    }
}
