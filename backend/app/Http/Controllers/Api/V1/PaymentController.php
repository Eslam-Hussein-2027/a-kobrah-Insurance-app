<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
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
     * Start an online payment. The app opens `checkout_url`, then polls GET /payments/{id}.
     */
    public function payOnline(Policy $policy): JsonResponse
    {
        $this->authorize('pay', $policy);

        $payment = $this->payments->startOnline($policy);

        return ApiResponse::created(new PaymentResource($payment), __('messages.payment.started'));
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
