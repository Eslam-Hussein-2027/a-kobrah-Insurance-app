<?php

namespace App\Models;

use App\Enums\ClaimMediaType;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ClaimMedia extends Model
{
    protected $table = 'claim_media';

    protected $fillable = [
        'claim_id',
        'file_path',
        'type',
        'image_hash',
    ];

    protected function casts(): array
    {
        return [
            'type' => ClaimMediaType::class,
        ];
    }

    public function claim(): BelongsTo
    {
        return $this->belongsTo(Claim::class);
    }
}
