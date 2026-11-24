<?php

namespace App\Http\Requests\Quote;

use App\Enums\TravelZone;
use App\Http\Requests\ApiRequest;
use Illuminate\Validation\Rule;

class TravelQuoteRequest extends ApiRequest
{
    protected function numericInputs(): array
    {
        return ['days', 'travellers'];
    }

    public function rules(): array
    {
        return [
            'zone' => ['required', Rule::enum(TravelZone::class)],
            'days' => ['required', 'integer', 'min:1', 'max:366'],
            'travellers' => ['required', 'integer', 'min:1', 'max:'.config('insurance.travel.max_travellers')],
        ];
    }

    public function zone(): TravelZone
    {
        return TravelZone::from($this->validated('zone'));
    }
}
