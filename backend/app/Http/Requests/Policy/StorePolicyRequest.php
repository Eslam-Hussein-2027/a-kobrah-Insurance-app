<?php

namespace App\Http\Requests\Policy;

use App\Http\Requests\ApiRequest;
use Carbon\CarbonImmutable;

class StorePolicyRequest extends ApiRequest
{
    public function rules(): array
    {
        $maxStart = now()->addDays((int) config('insurance.policy.max_start_days_ahead'))->toDateString();

        return [
            'vehicle_id' => ['required', 'integer', 'exists:vehicles,id'],
            'coverage_type_id' => ['required', 'integer', 'exists:coverage_types,id'],
            'start_date' => ['nullable', 'date_format:Y-m-d', 'after_or_equal:today', 'before_or_equal:'.$maxStart],
        ];
    }

    public function startDate(): ?CarbonImmutable
    {
        return $this->filled('start_date')
            ? CarbonImmutable::createFromFormat('Y-m-d', $this->validated('start_date'))->startOfDay()
            : null;
    }
}
