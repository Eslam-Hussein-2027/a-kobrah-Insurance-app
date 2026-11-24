<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Responses\ApiResponse;
use App\Services\Catalog\ProductCatalog;
use Illuminate\Http\JsonResponse;

/**
 * Public reference data for the app: product catalog and company information.
 */
class CatalogController extends Controller
{
    public function products(ProductCatalog $catalog): JsonResponse
    {
        return ApiResponse::success($catalog->all());
    }

    public function company(): JsonResponse
    {
        $company = (array) config('insurance.company');
        $english = app()->getLocale() === 'en';

        return ApiResponse::success([
            'name' => $english ? $company['name_en'] : $company['name_ar'],
            'phone' => $company['phone'],
            'website' => $company['website'],
            'address' => $company['address'],
            'branches' => array_map(fn (array $branch) => [
                'name' => $english ? $branch['name_en'] : $branch['name_ar'],
                'city' => $english ? $branch['city_en'] : $branch['city_ar'],
                'phone' => $branch['phone'],
                'is_head_office' => (bool) $branch['is_head_office'],
            ], (array) $company['branches']),
            'about' => (array) __('company.about'),
            'privacy' => (array) __('company.privacy'),
        ]);
    }
}
