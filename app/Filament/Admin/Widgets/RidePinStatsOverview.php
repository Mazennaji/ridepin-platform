<?php

namespace App\Filament\Admin\Widgets;

use App\Models\Ride;
use App\Models\Transaction;
use App\Models\User;
use Filament\Widgets\StatsOverviewWidget as BaseWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;

class RidePinStatsOverview extends BaseWidget
{
    protected function getStats(): array
    {
        $totalUsers = User::count();
        $totalDrivers = User::whereHas('role', fn ($q) => $q->where('name', 'driver'))->count();
        $totalRiders = User::whereHas('role', fn ($q) => $q->where('name', 'rider'))->count();

        $totalRides = Ride::count();
        $completedRides = Ride::where('status', 'completed')->count();
        $cancelledRides = Ride::where('status', 'cancelled')->count();
        $pendingRides = Ride::where('status', 'pending')->count();

        $revenue = Transaction::where('payment_status', 'paid')->sum('amount');

        return [
            Stat::make('Total Users', $totalUsers)
                ->description("$totalRiders riders · $totalDrivers drivers")
                ->color('primary'),

            Stat::make('Total Rides', $totalRides)
                ->description("$completedRides completed · $pendingRides pending")
                ->color('info'),

            Stat::make('Completed', $completedRides)
                ->description("$cancelledRides cancelled")
                ->color('success'),

            Stat::make('Revenue', '$' . number_format($revenue, 2))
                ->description('From paid transactions')
                ->color('warning'),
        ];
    }
}
