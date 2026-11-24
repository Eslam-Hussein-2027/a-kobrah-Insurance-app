<?php

namespace App\Models;

use App\Enums\TravelZone;
use Database\Factories\TravelRateFactory;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

/**
 * Travel tariff: price per traveller for a zone and a fixed trip length (admin-managed).
 *
 * @property int $id
 * @property TravelZone $zone
 * @property int $days
 * @property string $price
 * @property bool $is_active
 */
class TravelRate extends Model
{
    /** @use HasFactory<TravelRateFactory> */
    use HasFactory;

    protected $fillable = ['zone', 'days', 'price', 'is_active'];

    protected function casts(): array
    {
        return [
            'zone' => TravelZone::class,
            'days' => 'integer',
            'price' => 'decimal:2',
            'is_active' => 'boolean',
        ];
    }

    public function scopeActive(Builder $query): Builder
    {
        return $query->where('is_active', true);
    }
}
