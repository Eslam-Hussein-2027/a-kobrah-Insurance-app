<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Policy\StoreTravelPolicyRequest;
use App\Http\Requests\Quote\TravelQuoteRequest;
use App\Http\Resources\PolicyResource;
use App\Http\Responses\ApiResponse;
use App\Services\Policy\PolicyService;
use App\Services\Pricing\TravelQuoteService;
use Illuminate\Http\JsonResponse;

class TravelController extends Controller
{
    public function __construct(private readonly TravelQuoteService $quotes) {}

    /** Zones, trip lengths and prices for the app's forms. */
    public function options(): JsonResponse
    {
        return ApiResponse::success([
            'zones' => $this->quotes->options(),
            'max_travellers' => (int) config('insurance.travel.max_travellers'),
            'max_start_days_ahead' => (int) config('insurance.policy.max_start_days_ahead'),
            'currency' => config('insurance.currency'),
        ]);
    }

    /** Price preview only — nothing is persisted. */
    public function quote(TravelQuoteRequest $request): JsonResponse
    {
        $quote = $this->quotes->quote($request->zone(), (int) $request->validated('days'), (int) $request->validated('travellers'));

        return ApiResponse::success($quote->toArray());
    }

    public function store(StoreTravelPolicyRequest $request, PolicyService $policies): JsonResponse
    {
        $policy = $policies->createPendingTravel(
            $request->user(),
            $request->zone(),
            (int) $request->validated('days'),
            $request->startDate(),
            $request->travellers(),
        );

        return ApiResponse::created(
            new PolicyResource($policy->load(PolicyResource::RELATIONS)),
            __('messages.policy.created'),
        );
    }
}
