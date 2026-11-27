<?php

namespace App\Http\Resources;

use App\Enums\PaymentMethod;
use App\Enums\PaymentStatus;
use App\Models\Payment;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/** @mixin Payment */
class PaymentResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'policy_id' => $this->policy_id,
            'amount' => $this->amount,
            'currency' => config('insurance.currency'),
            'method' => $this->method->toArray(),
            'gateway' => $this->gateway,
            'pay_method' => $this->pay_method === null ? null : [
                'value' => $this->pay_method,
                'label' => __('payments.methods.'.$this->pay_method),
            ],
            'reference' => $this->gateway_ref,
            'status' => $this->status->toArray(),
            'failure_reason' => $this->failure_reason,
            'requires_refund' => $this->requires_refund,
            'paid_at' => $this->paid_at?->toIso8601String(),
            // OTP flow: no hosted page, the customer confirms with the code sent to their phone.
            'requires_otp' => $this->method === PaymentMethod::Online
                && $this->status === PaymentStatus::Pending
                && $this->gateway_ref !== null
                && $this->checkout_url === null,
            'checkout_url' => $this->when(
                $this->method === PaymentMethod::Online && $this->status === PaymentStatus::Pending,
                $this->checkout_url,
            ),
            'confirmed_by' => $this->whenLoaded('confirmedBy', fn () => $this->confirmedBy?->name),
            'policy' => new PolicyResource($this->whenLoaded('policy')),
            'created_at' => $this->created_at?->toIso8601String(),
        ];
    }
}
