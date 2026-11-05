<?php

namespace App\Http\Controllers\Api\V1\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\ConfirmOfficePaymentRequest;
use App\Http\Resources\PolicyResource;
use App\Http\Responses\ApiResponse;
use App\Models\Policy;
use App\Services\Policy\PolicyService;
use Illuminate\Http\JsonResponse;

class PolicyPaymentController extends Controller
{
    /**
     * "Pay at office": admin confirms the payment → policy becomes ACTIVE → PDF is queued.
     */
    public function confirmOffice(ConfirmOfficePaymentRequest $request, Policy $policy, PolicyService $policies): JsonResponse
    {
        $policy = $policies->confirmOfficePayment($policy, $request->user(), $request->validated('reference'));

        return ApiResponse::success(
            new PolicyResource($policy->load(['vehicle', 'coverageType'])),
            __('messages.policy.payment_confirmed'),
        );
    }
}
