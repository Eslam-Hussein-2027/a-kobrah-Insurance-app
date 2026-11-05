<?php

namespace App\Http\Controllers\Api\V1;

use App\Exceptions\BusinessRuleException;
use App\Http\Controllers\Controller;
use App\Http\Requests\Vehicle\StoreVehicleRequest;
use App\Http\Requests\Vehicle\UpdateVehicleRequest;
use App\Http\Resources\VehicleResource;
use App\Http\Responses\ApiResponse;
use App\Models\Vehicle;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class VehicleController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $vehicles = $request->user()->vehicles()->latest('id')->paginate(15);

        return ApiResponse::paginated($vehicles, VehicleResource::class);
    }

    public function store(StoreVehicleRequest $request): JsonResponse
    {
        $vehicle = $request->user()->vehicles()->create($request->validated());

        return ApiResponse::created(new VehicleResource($vehicle), __('messages.vehicle.created'));
    }

    public function show(Vehicle $vehicle): JsonResponse
    {
        $this->authorize('view', $vehicle);

        return ApiResponse::success(new VehicleResource($vehicle));
    }

    public function update(UpdateVehicleRequest $request, Vehicle $vehicle): JsonResponse
    {
        $this->authorize('update', $vehicle);

        // Pricing and identity data are frozen while a policy is pending or in force.
        if ($vehicle->hasBlockingPolicy()) {
            throw new BusinessRuleException(__('messages.vehicle.locked_by_policy'));
        }

        $vehicle->update($request->validated());

        return ApiResponse::success(new VehicleResource($vehicle), __('messages.vehicle.updated'));
    }

    public function destroy(Vehicle $vehicle): JsonResponse
    {
        $this->authorize('delete', $vehicle);

        // Keep the insurance history intact: vehicles with any policy cannot be deleted.
        if ($vehicle->policies()->exists()) {
            throw new BusinessRuleException(__('messages.vehicle.has_policies'));
        }

        $vehicle->delete();

        return ApiResponse::success(message: __('messages.vehicle.deleted'));
    }
}
