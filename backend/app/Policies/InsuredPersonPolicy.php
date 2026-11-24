<?php

namespace App\Policies;

use App\Models\InsuredPerson;
use App\Models\User;
use Illuminate\Auth\Access\Response;

class InsuredPersonPolicy
{
    public function view(User $user, InsuredPerson $person): Response
    {
        return $this->ownerOnly($user, $person);
    }

    public function update(User $user, InsuredPerson $person): Response
    {
        return $this->ownerOnly($user, $person);
    }

    public function delete(User $user, InsuredPerson $person): Response
    {
        return $this->ownerOnly($user, $person);
    }

    private function ownerOnly(User $user, InsuredPerson $person): Response
    {
        return $person->user_id === $user->id
            ? Response::allow()
            : Response::deny(__('messages.person.not_owner'));
    }
}
