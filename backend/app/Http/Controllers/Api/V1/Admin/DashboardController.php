<?php

namespace App\Http\Controllers\Api\V1\Admin;

use App\Http\Controllers\Controller;
use App\Http\Responses\ApiResponse;
use App\Services\Admin\DashboardStatsService;
use Illuminate\Http\JsonResponse;

class DashboardController extends Controller
{
    public function __invoke(DashboardStatsService $stats): JsonResponse
    {
        return ApiResponse::success($stats->summary());
    }
}
