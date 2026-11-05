<?php

namespace App\Models;

use App\Enums\PricingFactorType;
use Database\Factories\PricingFactorFactory;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

/**
 * A multiplier applied when the factor input falls in [min_value, max_value].
 * max_value = NULL means "and above".
 *
 * @property int $id
 * @property PricingFactorType $factor_type
 * @property int $min_value
 * @property int|null $max_value
 * @property string $multiplier
 */
class PricingFactor extends Model
{
    /** @use HasFactory<PricingFactorFactory> */
    use HasFactory;

    protected $fillable = [
        'factor_type',
        'min_value',
        'max_value',
        'multiplier',
    ];

    protected function casts(): array
    {
        return [
            'factor_type' => PricingFactorType::class,
            'min_value' => 'integer',
            'max_value' => 'integer',
            'multiplier' => 'decimal:3',
        ];
    }

    public function scopeOfType(Builder $query, PricingFactorType $type): Builder
    {
        return $query->where('factor_type', $type);
    }

    public function matches(int $value): bool
    {
        return $value >= $this->min_value
            && ($this->max_value === null || $value <= $this->max_value);
    }
}
