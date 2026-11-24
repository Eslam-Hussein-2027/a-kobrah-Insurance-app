<?php

namespace App\Http\Controllers\Api\V1\Admin;

use App\Enums\InsuranceProduct;
use App\Enums\InsuranceRequestStatus;
use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\RespondInsuranceRequestRequest;
use App\Http\Resources\InsuranceRequestResource;
use App\Http\Responses\ApiResponse;
use App\Models\InsuranceRequest;
use App\Services\Requests\InsuranceRequestService;
use App\Support\PhoneNumber;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class InsuranceRequestController extends Controller
{
    public function __construct(private readonly InsuranceRequestService $requests) {}

    public function index(Request $request): JsonResponse
    {
        $request->validate([
            'status' => ['nullable', Rule::enum(InsuranceRequestStatus::class)],
            'product' => ['nullable', Rule::enum(InsuranceProduct::class)],
            'search' => ['nullable', 'string', 'max:50'],
        ]);

        $search = trim((string) $request->input('search'));

        $requests = InsuranceRequest::query()
            ->with('user')
            ->when($request->filled('status'), fn (Builder $q) => $q->where('status', $request->input('status')))
            ->when($request->filled('product'), fn (Builder $q) => $q->where('product', $request->input('product')))
            ->when($search !== '', fn (Builder $q) => $q->where(fn (Builder $inner) => $inner
                ->where('request_no', 'like', "%{$search}%")
                ->orWhereHas('user', fn (Builder $user) => $user
                    ->where('name', 'like', "%{$search}%")
                    ->orWhere('phone', 'like', '%'.PhoneNumber::normalize($search).'%'))))
            ->latest('id')
            ->paginate(20);

        return ApiResponse::paginated($requests, InsuranceRequestResource::class);
    }

    public function show(InsuranceRequest $insuranceRequest): JsonResponse
    {
        return ApiResponse::success(new InsuranceRequestResource($insuranceRequest->load(['user', 'documents'])));
    }

    public function respond(RespondInsuranceRequestRequest $request, InsuranceRequest $insuranceRequest): JsonResponse
    {
        $updated = $this->requests->respond(
            $insuranceRequest,
            $request->user(),
            $request->status(),
            $request->validated('reply'),
            $request->quotedAmount(),
        );

        return ApiResponse::success(
            new InsuranceRequestResource($updated->load(['user', 'documents'])),
            __('messages.request.replied'),
        );
    }
}
