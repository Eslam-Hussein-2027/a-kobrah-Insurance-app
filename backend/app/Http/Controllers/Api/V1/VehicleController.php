<?php

namespace App\Http\Controllers\Api\V1;

use App\Enums\LicensePurpose;
use App\Enums\LicensingAuthority;
use App\Enums\ManufactureCountry;
use App\Enums\VehicleColor;
use App\Exceptions\BusinessRuleException;
use App\Http\Controllers\Controller;
use App\Http\Requests\Vehicle\StoreVehicleRequest;
use App\Http\Requests\Vehicle\UpdateVehicleRequest;
use App\Http\Resources\VehicleResource;
use App\Http\Responses\ApiResponse;
use App\Models\Vehicle;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Lang;

class VehicleController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $vehicles = $request->user()->vehicles()->latest('id')->paginate(15);

        return ApiResponse::paginated($vehicles, VehicleResource::class);
    }

    /** Choices for the add / edit vehicle form. */
    public function options(): JsonResponse
    {
        $labels = fn (array $cases) => array_map(fn ($case) => $case->toArray(), $cases);

        return ApiResponse::success([
            'makes' => array_map(fn (string $make) => [
                'value' => $make,
                'label' => Lang::has("vehicles.makes.{$make}") ? __("vehicles.makes.{$make}") : $make,
            ], (array) config('vehicles.makes')),
            'colors' => $labels(VehicleColor::cases()),
            'countries' => $labels(ManufactureCountry::cases()),
            'license_purposes' => $labels(LicensePurpose::cases()),
            'licensing_authorities' => $labels(LicensingAuthority::cases()),
            'years' => ['min' => (int) config('insurance.validation.min_vehicle_year'), 'max' => (int) now()->year + 1],
            'seats' => ['min' => (int) config('vehicles.seats.min'), 'max' => (int) config('vehicles.seats.max')],
        ]);
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
