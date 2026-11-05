<?php

namespace App\Http\Controllers\Api\V1;

use App\Enums\PolicyVerificationResult;
use App\Http\Controllers\Controller;
use App\Http\Requests\Policy\VerifyPolicyRequest;
use App\Http\Responses\ApiResponse;
use App\Services\Policy\PolicyVerificationService;
use Illuminate\Http\JsonResponse;

/**
 * Public, rate-limited. Returns validity only — no personal data.
 */
class PolicyVerificationController extends Controller
{
    public function __invoke(VerifyPolicyRequest $request, PolicyVerificationService $verifier): JsonResponse
    {
        ['result' => $result, 'policy' => $policy] = $verifier->verify(
            $request->validated('policy_no'),
            $request->validated('plate_no'),
        );

        $data = ['result' => $result->toArray()];

        if ($policy !== null && $result !== PolicyVerificationResult::NotFound) {
            $data['policy_no'] = $policy->policy_no;
            $data['coverage_type'] = $policy->coverageType->localizedName();
            $data['start_date'] = $policy->start_date->toDateString();
            $data['end_date'] = $policy->end_date->toDateString();
        }

        return ApiResponse::success($data, $result->label());
    }
}
