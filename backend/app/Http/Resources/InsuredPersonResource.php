<?php

namespace App\Http\Resources;

use App\Models\InsuredPerson;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/** @mixin InsuredPerson */
class InsuredPersonResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'full_name' => $this->full_name,
            'relationship' => $this->relationship->toArray(),
            'birth_date' => $this->birth_date->toDateString(),
            'age' => $this->ageInYears(),
            'passport_no' => $this->passport_no,
            'national_id' => $this->national_id,
        ];
    }
}
