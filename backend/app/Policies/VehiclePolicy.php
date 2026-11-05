<?php

namespace App\Policies;

use App\Models\User;
use App\Models\Vehicle;
use Illuminate\Auth\Access\Response;

class VehiclePolicy
{
    public function view(User $user, Vehicle $vehicle): Response
    {
        return $this->owns($user, $vehicle) || $user->isAdmin()
            ? Response::allow()
            : Response::deny(__('messages.vehicle.not_owner'));
    }

    public function update(User $user, Vehicle $vehicle): Response
    {
        return $this->ownerOnly($user, $vehicle);
    }

    public function delete(User $user, Vehicle $vehicle): Response
    {
        return $this->ownerOnly($user, $vehicle);
    }

    /** Request a quote or buy a policy for this vehicle. */
    public function insure(User $user, Vehicle $vehicle): Response
    {
        return $this->ownerOnly($user, $vehicle);
    }

    private function ownerOnly(User $user, Vehicle $vehicle): Response
    {
        return $this->owns($user, $vehicle)
            ? Response::allow()
            : Response::deny(__('messages.vehicle.not_owner'));
    }

    private function owns(User $user, Vehicle $vehicle): bool
    {
        return $vehicle->user_id === $user->id;
    }
}
