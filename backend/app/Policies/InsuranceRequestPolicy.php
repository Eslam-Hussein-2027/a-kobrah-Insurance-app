<?php

namespace App\Policies;

use App\Models\InsuranceRequest;
use App\Models\User;
use Illuminate\Auth\Access\Response;

class InsuranceRequestPolicy
{
    public function view(User $user, InsuranceRequest $request): Response
    {
        return $request->user_id === $user->id || $user->isAdmin()
            ? Response::allow()
            : Response::deny(__('messages.request.not_owner'));
    }

    public function cancel(User $user, InsuranceRequest $request): Response
    {
        return $request->user_id === $user->id
            ? Response::allow()
            : Response::deny(__('messages.request.not_owner'));
    }

    public function respond(User $user, InsuranceRequest $request): Response
    {
        return $user->isAdmin() ? Response::allow() : Response::deny();
    }
}
