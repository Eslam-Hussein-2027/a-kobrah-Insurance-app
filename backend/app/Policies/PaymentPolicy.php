<?php

namespace App\Policies;

use App\Models\Payment;
use App\Models\User;
use Illuminate\Auth\Access\Response;

class PaymentPolicy
{
    public function view(User $user, Payment $payment): Response
    {
        return $user->isAdmin() || $payment->policy->isOwnedBy($user)
            ? Response::allow()
            : Response::deny(__('messages.policy.not_owner'));
    }
}
