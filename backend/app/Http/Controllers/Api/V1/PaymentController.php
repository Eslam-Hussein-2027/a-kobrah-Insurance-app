<?php

namespace App\Http\Controllers\Api\V1;

use App\Enums\PaymentStatus;
use App\Http\Controllers\Controller;
use App\Http\Requests\Payment\ConfirmPaymentRequest;
use App\Http\Requests\Payment\PayOnlineRequest;
use App\Http\Resources\PaymentResource;
use App\Http\Responses\ApiResponse;
use App\Models\Payment;
use App\Models\Policy;
use App\Services\Payments\PaymentService;
use Illuminate\Http\JsonResponse;

class PaymentController extends Controller
{
    public function __construct(private readonly PaymentService $payments) {}

    /**
     * How the app should collect the payment: hosted page (redirect) or phone + code (otp), and the methods.
     */
    public function options(): JsonResponse
    {
        return ApiResponse::success($this->payments->options());
    }

    /**
     * Start an online payment.
     *  - redirect flow: the app opens `checkout_url`, then polls GET /payments/{id}
     *  - otp flow: the customer receives a code and the app sends it to POST /payments/{id}/confirm
     */
    public function payOnline(PayOnlineRequest $request, Policy $policy): JsonResponse
    {
        $this->authorize('pay', $policy);

        $payment = $this->payments->startOnline($policy, $request->checkoutInput());

        return ApiResponse::created(
            new PaymentResource($payment),
            $payment->checkout_url === null ? __('messages.payment.otp_sent') : __('messages.payment.started'),
        );
    }

    /** OTP flow: the code the customer received by SMS. */
    public function confirm(ConfirmPaymentRequest $request, Payment $payment): JsonResponse
    {
        $this->authorize('view', $payment);

        $payment = $this->payments->confirmOtp($payment, $request->validated('otp'));

        return ApiResponse::success(
            new PaymentResource($payment),
            match ($payment->status) {
                PaymentStatus::Paid => __('messages.payment.paid'),
                PaymentStatus::Failed => __('messages.payment.declined'),
                default => __('messages.payment.processing'),
            },
        );
    }

    /**
     * Current status; while pending, the provider is asked again (pull model complements webhooks).
     */
    public function show(Payment $payment): JsonResponse
    {
        $this->authorize('view', $payment);

        $payment = $this->payments->sync($payment)->load('policy.vehicle', 'policy.coverageType');

        return ApiResponse::success(new PaymentResource($payment));
    }
}
