<?php

namespace App\Http\Controllers\Api\V1;

use App\Enums\InsuranceRequestStatus;
use App\Http\Controllers\Controller;
use App\Http\Requests\InsuranceRequest\StoreInsuranceRequestRequest;
use App\Http\Resources\InsuranceRequestResource;
use App\Http\Responses\ApiResponse;
use App\Models\InsuranceRequest;
use App\Services\Requests\InsuranceRequestService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class InsuranceRequestController extends Controller
{
    public function __construct(private readonly InsuranceRequestService $requests) {}

    public function index(Request $request): JsonResponse
    {
        $request->validate(['status' => ['nullable', Rule::enum(InsuranceRequestStatus::class)]]);

        $requests = $request->user()->insuranceRequests()
            ->when($request->filled('status'), fn ($q) => $q->where('status', $request->input('status')))
            ->latest('id')
            ->paginate(15);

        return ApiResponse::paginated($requests, InsuranceRequestResource::class);
    }

    public function store(StoreInsuranceRequestRequest $request): JsonResponse
    {
        $insuranceRequest = $this->requests->submit(
            $request->user(),
            $request->product(),
            $request->kind(),
            (array) $request->validated('answers', []),
            $request->validated('notes'),
            $request->documents(),
        );

        return ApiResponse::created(
            new InsuranceRequestResource($insuranceRequest->load('documents')),
            __('messages.request.created'),
        );
    }

    public function show(InsuranceRequest $insuranceRequest): JsonResponse
    {
        $this->authorize('view', $insuranceRequest);

        return ApiResponse::success(new InsuranceRequestResource($insuranceRequest->load('documents')));
    }

    public function cancel(InsuranceRequest $insuranceRequest): JsonResponse
    {
        $this->authorize('cancel', $insuranceRequest);

        $this->requests->cancel($insuranceRequest);

        return ApiResponse::success(
            new InsuranceRequestResource($insuranceRequest->load('documents')),
            __('messages.request.cancelled'),
        );
    }
}
