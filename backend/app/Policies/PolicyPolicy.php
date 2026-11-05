<?php

namespace App\Policies;

use App\Models\Policy;
use App\Models\User;
use Illuminate\Auth\Access\Response;

/**
 * Authorization for insurance policies (App\Models\Policy).
 */
class PolicyPolicy
{
    public function view(User $user, Policy $policy): Response
    {
        return $user->isAdmin() || $policy->isOwnedBy($user)
            ? Response::allow()
            : Response::deny(__('messages.policy.not_owner'));
    }

    /**
     * Only the policy owner, and only while the policy is ACTIVE.
     */
    public function download(User $user, Policy $policy): Response
    {
        if (! $policy->isOwnedBy($user)) {
            return Response::deny(__('messages.policy.not_owner'));
        }

        if (! $policy->isActive()) {
            return Response::deny(__('messages.policy.not_active'));
        }

        return Response::allow();
    }

    public function cancel(User $user, Policy $policy): Response
    {
        return $policy->isOwnedBy($user)
            ? Response::allow()
            : Response::deny(__('messages.policy.not_owner'));
    }
}
