<?php

namespace App\Http\Controllers\Api\V1\Admin;

use App\Enums\PricingFactorType;
use App\Http\Controllers\Controller;
use App\Http\Resources\Admin\AdminCoverageTypeResource;
use App\Http\Resources\Admin\PricingFactorResource;
use App\Http\Responses\ApiResponse;
use App\Models\CoverageType;
use App\Models\PricingFactor;
use App\Services\Admin\PricingFactorService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

/**
 * Admin tariff management: coverage base prices and the factor bands
 * (premium = base_price × age × engine × claims history). Changes apply to new quotes only;
 * existing policies keep their pricing snapshot.
 */
class PricingController extends Controller
{
    public function __construct(private readonly PricingFactorService $factors) {}

    public function index(): JsonResponse
    {
        return ApiResponse::success([
            'coverage_types' => AdminCoverageTypeResource::collection(CoverageType::query()->orderBy('id')->get()),
            'factors' => PricingFactorResource::collection(
                PricingFactor::query()->orderBy('factor_type')->orderBy('min_value')->get(),
            ),
            'factor_types' => array_map(fn (PricingFactorType $t) => $t->toArray(), PricingFactorType::cases()),
            'gaps' => $this->factors->gaps(),
        ]);
    }

    public function updateCoverageType(Request $request, CoverageType $coverageType): JsonResponse
    {
        $data = $request->validate([
            'name' => ['sometimes', 'string', 'max:100'],
            'name_en' => ['sometimes', 'nullable', 'string', 'max:100'],
            'description' => ['sometimes', 'nullable', 'string', 'max:500'],
            'base_price' => ['sometimes', 'numeric', 'min:0', 'max:1000000'],
            'is_active' => ['sometimes', 'boolean'],
        ]);

        $coverageType->update($data);

        return ApiResponse::success(new AdminCoverageTypeResource($coverageType), __('messages.pricing.saved'));
    }

    public function storeFactor(Request $request): JsonResponse
    {
        $factor = $this->factors->save($this->validateFactor($request));

        return ApiResponse::created(new PricingFactorResource($factor), __('messages.pricing.saved'));
    }

    public function updateFactor(Request $request, PricingFactor $pricingFactor): JsonResponse
    {
        $factor = $this->factors->save($this->validateFactor($request), $pricingFactor);

        return ApiResponse::success(new PricingFactorResource($factor), __('messages.pricing.saved'));
    }

    public function destroyFactor(PricingFactor $pricingFactor): JsonResponse
    {
        $pricingFactor->delete();

        return ApiResponse::success(message: __('messages.pricing.deleted'));
    }

    /**
     * @return array{factor_type: string, min_value: int, max_value: ?int, multiplier: numeric}
     */
    private function validateFactor(Request $request): array
    {
        return $request->validate([
            'factor_type' => ['required', Rule::enum(PricingFactorType::class)],
            'min_value' => ['required', 'integer', 'min:0'],
            'max_value' => ['nullable', 'integer', 'gte:min_value'],
            'multiplier' => ['required', 'numeric', 'min:0.1', 'max:10'],
        ]) + ['max_value' => null];
    }
}
