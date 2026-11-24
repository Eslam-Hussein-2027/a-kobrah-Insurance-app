<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

/**
 * A file attached to an insurance request (stored on the private uploads disk).
 *
 * @property int $id
 * @property int $insurance_request_id
 * @property string $document_key
 * @property string $path
 * @property string $original_name
 * @property string $mime_type
 * @property int $size
 */
class InsuranceRequestDocument extends Model
{
    protected $fillable = [
        'document_key',
        'path',
        'original_name',
        'mime_type',
        'size',
    ];

    protected function casts(): array
    {
        return ['size' => 'integer'];
    }

    public function request(): BelongsTo
    {
        return $this->belongsTo(InsuranceRequest::class, 'insurance_request_id');
    }
}
