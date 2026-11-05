<?php

namespace App\Http\Controllers\Api\V1;

use App\Enums\PolicyStatus;
use App\Http\Controllers\Controller;
use App\Http\Requests\Policy\StorePolicyRequest;
use App\Http\Resources\PolicyResource;
use App\Http\Responses\ApiResponse;
use App\Models\CoverageType;
use App\Models\Policy;
use App\Models\Vehicle;
use App\Services\Policy\PolicyPdfService;
use App\Services\Policy\PolicyService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;
use Symfony\Component\HttpFoundation\StreamedResponse;

class PolicyController extends Controller
{
    public function __construct(private readonly PolicyService $policies) {}

    public function index(Request $request): JsonResponse
    {
        $request->validate([
            'status' => ['nullable', Rule::enum(PolicyStatus::class)],
            'vehicle_id' => ['nullable', 'integer'],
        ]);

        $policies = $request->user()->policies()
            ->with(['vehicle', 'coverageType'])
            ->when($request->filled('status'), fn ($q) => $q->where('policies.status', $request->input('status')))
            ->when($request->filled('vehicle_id'), fn ($q) => $q->where('policies.vehicle_id', $request->integer('vehicle_id')))
            ->latest('policies.id')
            ->paginate(15);

        return ApiResponse::paginated($policies, PolicyResource::class);
    }

    public function store(StorePolicyRequest $request): JsonResponse
    {
        $vehicle = Vehicle::query()->findOrFail($request->validated('vehicle_id'));
        $this->authorize('insure', $vehicle);

        $policy = $this->policies->createPending(
            $request->user(),
            $vehicle,
            CoverageType::query()->findOrFail($request->validated('coverage_type_id')),
            $request->startDate(),
        );

        return ApiResponse::created(
            new PolicyResource($policy->load(['vehicle', 'coverageType'])),
            __('messages.policy.created'),
        );
    }

    public function show(Policy $policy): JsonResponse
    {
        $this->authorize('view', $policy);

        return ApiResponse::success(new PolicyResource($policy->load(['vehicle', 'coverageType'])));
    }

    public function cancel(Policy $policy): JsonResponse
    {
        $this->authorize('cancel', $policy);

        $this->policies->cancelPending($policy);

        return ApiResponse::success(
            new PolicyResource($policy->load(['vehicle', 'coverageType'])),
            __('messages.policy.cancelled'),
        );
    }

    /**
     * A4 printable PDF. Owner only, ACTIVE only (see PolicyPolicy::download).
     */
    public function downloadPdf(Policy $policy, PolicyPdfService $pdf): StreamedResponse
    {
        $this->authorize('download', $policy);

        return $pdf->disk()->download($pdf->ensure($policy), $policy->policy_no.'.pdf', [
            'Content-Type' => 'application/pdf',
            'Cache-Control' => 'private, no-store',
        ]);
    }
}
