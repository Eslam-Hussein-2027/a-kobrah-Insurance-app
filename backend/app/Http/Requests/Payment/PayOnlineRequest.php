<?php

namespace App\Http\Requests\Payment;

use App\Http\Requests\ApiRequest;
use App\Services\Payments\CheckoutInput;
use Illuminate\Validation\Rule;

/**
 * Optional for hosted-checkout gateways; OTP gateways (DPAY) need the wallet phone number
 * (the service checks that, so a missing value gets one clear message).
 */
class PayOnlineRequest extends ApiRequest
{
    public function rules(): array
    {
        return [
            'phone' => ['nullable', 'string', 'regex:'.config('insurance.validation.phone_regex')],
            'pay_method' => ['nullable', 'string', Rule::in(array_keys((array) config('payments.methods')))],
        ];
    }

    public function checkoutInput(): CheckoutInput
    {
        return new CheckoutInput($this->validated('phone'), $this->validated('pay_method'));
    }
}
