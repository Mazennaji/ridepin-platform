<?php

namespace Database\Seeders;

use App\Models\DriverProfile;
use App\Models\Role;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        // 1. Roles — created first because users reference them.
        $adminRole  = Role::firstOrCreate(['name' => 'admin']);
        $riderRole  = Role::firstOrCreate(['name' => 'rider']);
        $driverRole = Role::firstOrCreate(['name' => 'driver']);

        // 2. Admin user — matches the demo credentials in your README.
        User::firstOrCreate(
            ['email' => 'admin@ridepin.com'],
            [
                'name'     => 'Admin',
                'password' => Hash::make('password123'),
                'role_id'  => $adminRole->id,
            ]
        );

        // 3. Sample rider — for walking the ride lifecycle.
        User::firstOrCreate(
            ['email' => 'rider@ridepin.com'],
            [
                'name'     => 'Sample Rider',
                'password' => Hash::make('password123'),
                'role_id'  => $riderRole->id,
            ]
        );

        // 4. Sample driver + driver profile.
        $driver = User::firstOrCreate(
            ['email' => 'driver@ridepin.com'],
            [
                'name'     => 'Sample Driver',
                'password' => Hash::make('password123'),
                'role_id'  => $driverRole->id,
            ]
        );

        DriverProfile::firstOrCreate(
            ['user_id' => $driver->id],
            [
                'license_number'      => 'LIC-123456',
                'vehicle_type'        => 'Sedan',
                'vehicle_model'       => 'Toyota Corolla 2020',
                'plate_number'        => 'ABC-1234',
                'is_available'        => true,
                'verification_status' => true,
            ]
        );
    }
}
