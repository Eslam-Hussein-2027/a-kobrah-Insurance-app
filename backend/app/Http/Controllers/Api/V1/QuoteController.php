<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Quote\EstimateQuoteRequest;
use App\Http\Requests\Quote\QuoteRequest;
use App\Http\Resources\QuoteResource;
use App\Http\Responses\ApiResponse;
use App\Models\CoverageType;
use App\Models\Vehicle;
use App\Services\Pricing\QuoteService;
use Illuminate\Http\JsonResponse;

class QuoteController extends Controller
{
    /**
     * Price preview only — nothing is persisted. The premium is recalculated when the policy is created.
     */
    public function store(QuoteRequest $request, QuoteService $quotes): JsonResponse
    {
        $vehicle = Vehicle::query()->findOrFail($request->validated('vehicle_id'));
        $this->authorize('insure', $vehicle);

        $coverageType = CoverageType::query()->findOrFail($request->validated('coverage_type_id'));

        return ApiResponse::success(new QuoteResource($quotes->calculate($vehicle, $coverageType)));
    }

    /**
     * "Know the price" calculator for a vehicle that is not registered yet (compulsory coverage by default).
     */
    public function estimate(EstimateQuoteRequest $request, QuoteService $quotes): JsonResponse
    {
        $coverageType = $request->filled('coverage_type_id')
            ? CoverageType::query()->findOrFail($request->validated('coverage_type_id'))
            : CoverageType::query()->active()->where('is_mandatory', true)->orderBy('id')->firstOrFail();

        return ApiResponse::success(new QuoteResource($quotes->estimate(
            $request->user(),
            (int) $request->validated('manufacture_year'),
            (int) $request->validated('engine_cc'),
            $coverageType,
        )));
    }
}
