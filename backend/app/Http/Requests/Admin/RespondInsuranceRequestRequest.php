<?php

namespace App\Http\Requests\Admin;

use App\Enums\InsuranceRequestStatus;
use App\Http\Requests\ApiRequest;
use Illuminate\Validation\Rule;

class RespondInsuranceRequestRequest extends ApiRequest
{
    protected function numericInputs(): array
    {
        return ['quoted_amount'];
    }

    public function rules(): array
    {
        return [
            'status' => ['required', Rule::in(array_map(fn ($s) => $s->value, InsuranceRequestStatus::staffTargets()))],
            'reply' => ['nullable', 'string', 'max:2000', 'required_if:status,'.InsuranceRequestStatus::Rejected->value],
            'quoted_amount' => [
                'nullable',
                'numeric',
                'min:1',
                'max:1000000000',
                'required_if:status,'.InsuranceRequestStatus::Quoted->value,
            ],
        ];
    }

    public function status(): InsuranceRequestStatus
    {
        return InsuranceRequestStatus::from($this->validated('status'));
    }

    public function quotedAmount(): ?string
    {
        $amount = $this->validated('quoted_amount');

        return $amount === null ? null : number_format((float) $amount, 2, '.', '');
    }
}
