<?php

namespace App\Models;

use Carbon\CarbonImmutable;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

/**
 * Traveller covered by a travel policy (snapshot taken when the policy is created).
 *
 * @property int $id
 * @property int $policy_id
 * @property int|null $insured_person_id
 * @property string $full_name
 * @property CarbonImmutable $birth_date
 * @property string $passport_no
 */
class PolicyTraveller extends Model
{
    protected $fillable = ['insured_person_id', 'full_name', 'birth_date', 'passport_no'];

    protected function casts(): array
    {
        return ['birth_date' => 'date'];
    }

    public function policy(): BelongsTo
    {
        return $this->belongsTo(Policy::class);
    }
}
