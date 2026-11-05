<?php

namespace App\Http\Controllers\Api\V1\Admin;

use App\Enums\UserRole;
use App\Http\Controllers\Controller;
use App\Http\Resources\Admin\CustomerResource;
use App\Http\Responses\ApiResponse;
use App\Models\User;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CustomerController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $request->validate(['search' => ['nullable', 'string', 'max:50']]);

        $customers = User::query()
            ->where('role', UserRole::Customer)
            ->withCount(['vehicles', 'policies'])
            ->when($request->filled('search'), function (Builder $q) use ($request) {
                $like = '%'.addcslashes(trim((string) $request->input('search')), '%_\\').'%';
                $q->where(fn (Builder $w) => $w->where('name', 'like', $like)
                    ->orWhere('phone', 'like', $like)
                    ->orWhere('national_id', 'like', $like));
            })
            ->latest('id')
            ->paginate(20);

        return ApiResponse::paginated($customers, CustomerResource::class);
    }

    public function show(User $customer): JsonResponse
    {
        $this->ensureCustomer($customer);

        $customer->load(['vehicles', 'policies.vehicle.user', 'policies.coverageType'])->loadCount(['vehicles', 'policies']);

        return ApiResponse::success(new CustomerResource($customer));
    }

    /** Block / unblock a customer. Blocking revokes all their app sessions. */
    public function update(Request $request, User $customer): JsonResponse
    {
        $this->ensureCustomer($customer);
        $data = $request->validate(['is_active' => ['required', 'boolean']]);

        $customer->update(['is_active' => $data['is_active']]);
        if (! $customer->is_active) {
            $customer->tokens()->delete();
        }

        return ApiResponse::success(
            new CustomerResource($customer->loadCount(['vehicles', 'policies'])),
            __($customer->is_active ? 'messages.customer.activated' : 'messages.customer.blocked'),
        );
    }

    private function ensureCustomer(User $user): void
    {
        abort_unless($user->role === UserRole::Customer, 404);
    }
}
