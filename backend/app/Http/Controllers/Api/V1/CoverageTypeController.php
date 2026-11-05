<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\CoverageTypeResource;
use App\Http\Responses\ApiResponse;
use App\Models\CoverageType;
use Illuminate\Http\JsonResponse;

class CoverageTypeController extends Controller
{
    public function index(): JsonResponse
    {
        $types = CoverageType::query()->active()->orderByDesc('is_mandatory')->orderBy('base_price')->get();

        return ApiResponse::success(CoverageTypeResource::collection($types));
    }
}
