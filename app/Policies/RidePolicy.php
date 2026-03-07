<?php

namespace App\Policies;

use App\Models\Ride;
use App\Models\User;

class RidePolicy
{
    public function viewAny(User $user): bool
    {
        return $user->isAdmin() || $user->isRider() || $user->isDriver();
    }

    public function view(User $user, Ride $ride): bool
    {
        return $user->isAdmin()
            || $ride->rider_id === $user->id
            || $ride->driver_id === $user->id;
    }

    public function create(User $user): bool
    {
        return $user->isRider();
    }

    public function cancel(User $user, Ride $ride): bool
    {
        return $user->isRider()
            && $ride->rider_id === $user->id
            && $ride->status === 'pending';
    }

    public function accept(User $user, Ride $ride): bool
    {
        return $user->isDriver() && $ride->status === 'pending';
    }

    public function start(User $user, Ride $ride): bool
    {
        return $user->isDriver()
            && $ride->driver_id === $user->id
            && $ride->status === 'accepted';
    }

    public function complete(User $user, Ride $ride): bool
    {
        return $user->isDriver()
            && $ride->driver_id === $user->id
            && $ride->status === 'started';
    }
}
