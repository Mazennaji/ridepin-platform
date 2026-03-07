<?php

namespace App\Providers;

use App\Models\Ride;
use App\Policies\RidePolicy;
use Illuminate\Foundation\Support\Providers\AuthServiceProvider as ServiceProvider;

class AuthServiceProvider extends ServiceProvider
{
    protected $policies = [
        Ride::class => RidePolicy::class,
    ];

    public function boot(): void
    {
        //
    }
}
