<?php

namespace App\Http\Requests\Policy;

use App\Enums\TravelZone;
use App\Http\Requests\ApiRequest;
use App\Models\InsuredPerson;
use Carbon\CarbonImmutable;
use Illuminate\Support\Collection;
use Illuminate\Validation\Rule;

class StoreTravelPolicyRequest extends ApiRequest
{
    protected function numericInputs(): array
    {
        return ['days'];
    }

    public function rules(): array
    {
        $maxStart = now()->addDays((int) config('insurance.policy.max_start_days_ahead'))->toDateString();

        return [
            'zone' => ['required', Rule::enum(TravelZone::class)],
            'days' => ['required', 'integer', 'min:1', 'max:366'],
            'start_date' => ['required', 'date_format:Y-m-d', 'after_or_equal:today', 'before_or_equal:'.$maxStart],
            'person_ids' => ['required', 'array', 'min:1', 'max:'.config('insurance.travel.max_travellers')],
            'person_ids.*' => [
                'integer',
                'distinct',
                Rule::exists('insured_persons', 'id')->where('user_id', $this->user()?->id),
            ],
        ];
    }

    public function zone(): TravelZone
    {
        return TravelZone::from($this->validated('zone'));
    }

    public function startDate(): CarbonImmutable
    {
        return CarbonImmutable::createFromFormat('Y-m-d', $this->validated('start_date'))->startOfDay();
    }

    /**
     * @return Collection<int, InsuredPerson>
     */
    public function travellers(): Collection
    {
        $ids = array_map('intval', $this->validated('person_ids'));

        // Keep the order chosen in the app (first = main traveller).
        return $this->user()->insuredPersons()->whereKey($ids)->get()
            ->sortBy(fn (InsuredPerson $person) => array_search($person->id, $ids, true))
            ->values();
    }
}
