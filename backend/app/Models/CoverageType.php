<?php

namespace App\Models;

use Database\Factories\CoverageTypeFactory;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

/**
 * @property int $id
 * @property string $code
 * @property string $name
 * @property string|null $name_en
 * @property string $base_price
 * @property bool $is_mandatory
 * @property bool $is_active
 */
class CoverageType extends Model
{
    /** @use HasFactory<CoverageTypeFactory> */
    use HasFactory;

    public const THIRD_PARTY = 'THIRD_PARTY';

    public const COMPREHENSIVE = 'COMPREHENSIVE';

    protected $fillable = [
        'code',
        'name',
        'name_en',
        'description',
        'base_price',
        'is_mandatory',
        'is_active',
    ];

    protected function casts(): array
    {
        return [
            'base_price' => 'decimal:2',
            'is_mandatory' => 'boolean',
            'is_active' => 'boolean',
        ];
    }

    public function policies(): HasMany
    {
        return $this->hasMany(Policy::class);
    }

    public function scopeActive(Builder $query): Builder
    {
        return $query->where('is_active', true);
    }

    /** Name in the current request locale (Arabic is the primary language). */
    public function localizedName(): string
    {
        return app()->getLocale() === 'en' && filled($this->name_en) ? $this->name_en : $this->name;
    }
}
