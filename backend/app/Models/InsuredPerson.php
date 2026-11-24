<?php

namespace App\Models;

use App\Enums\PersonRelationship;
use Carbon\CarbonImmutable;
use Database\Factories\InsuredPersonFactory;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

/**
 * Someone the customer insures (themselves or a family member).
 *
 * @property int $id
 * @property int $user_id
 * @property string $full_name
 * @property PersonRelationship $relationship
 * @property CarbonImmutable $birth_date
 * @property string|null $passport_no
 * @property string|null $national_id
 */
class InsuredPerson extends Model
{
    /** @use HasFactory<InsuredPersonFactory> */
    use HasFactory;

    protected $table = 'insured_persons';

    protected $fillable = [
        'full_name',
        'relationship',
        'birth_date',
        'passport_no',
        'national_id',
    ];

    protected function casts(): array
    {
        return [
            'relationship' => PersonRelationship::class,
            'birth_date' => 'date',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function ageInYears(): int
    {
        return (int) $this->birth_date->diffInYears(CarbonImmutable::today());
    }
}
