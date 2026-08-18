<?php

namespace Tests\Feature;

use App\Models\DriverProfile;
use App\Models\Role;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class RideLifecycleTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        Role::firstOrCreate(['name' => 'admin']);
        Role::firstOrCreate(['name' => 'rider']);
        Role::firstOrCreate(['name' => 'driver']);
    }

    private function makeRider(): User
    {
        return User::create([
            'name' => 'Rider',
            'email' => 'rider_'.uniqid().'@ridepin.com',
            'password' => Hash::make('password123'),
            'role_id' => Role::where('name', 'rider')->first()->id,
        ]);
    }

    private function makeDriver(): User
    {
        $driver = User::create([
            'name' => 'Driver',
            'email' => 'driver_'.uniqid().'@ridepin.com',
            'password' => Hash::make('password123'),
            'role_id' => Role::where('name', 'driver')->first()->id,
        ]);
        DriverProfile::create([
            'user_id' => $driver->id,
            'license_number' => 'LIC-TEST',
            'vehicle_type' => 'Sedan',
            'vehicle_model' => 'Test Model',
            'plate_number' => 'TEST-123',
            'is_available' => true,
            'verification_status' => true,
        ]);
        return $driver;
    }

    private function createRide(User $rider): int
    {
        Sanctum::actingAs($rider);
        $res = $this->postJson('/api/rides', [
            'pickup_location' => 'A',
            'dropoff_location' => 'B',
        ]);
        $res->assertStatus(201);
        return $res->json('ride.id');
    }

    public function test_rider_can_create_a_pending_ride(): void
    {
        $rider = $this->makeRider();
        Sanctum::actingAs($rider);

        $res = $this->postJson('/api/rides', [
            'pickup_location' => 'Baabda',
            'dropoff_location' => 'Beirut',
        ]);

        $res->assertStatus(201)
            ->assertJsonPath('ride.status', 'pending');
    }

    public function test_full_lifecycle_generates_a_transaction(): void
    {
        $rider = $this->makeRider();
        $driver = $this->makeDriver();
        $rideId = $this->createRide($rider);

        Sanctum::actingAs($driver);

        $this->postJson("/api/driver/rides/{$rideId}/accept")
            ->assertStatus(200)->assertJsonPath('ride.status', 'accepted');

        $this->postJson("/api/driver/rides/{$rideId}/start")
            ->assertStatus(200)->assertJsonPath('ride.status', 'started');

        $this->postJson("/api/driver/rides/{$rideId}/complete")
            ->assertStatus(200)->assertJsonPath('ride.status', 'completed');

        $this->assertDatabaseHas('transactions', [
            'ride_id' => $rideId,
            'payment_status' => 'paid',
        ]);
    }

    public function test_rider_can_rate_a_completed_ride(): void
    {
        $rider = $this->makeRider();
        $driver = $this->makeDriver();
        $rideId = $this->createRide($rider);

        Sanctum::actingAs($driver);
        $this->postJson("/api/driver/rides/{$rideId}/accept");
        $this->postJson("/api/driver/rides/{$rideId}/start");
        $this->postJson("/api/driver/rides/{$rideId}/complete");

        Sanctum::actingAs($rider);
        $this->postJson("/api/rides/{$rideId}/rate", [
            'score' => 5,
            'comment' => 'Great',
        ])->assertStatus(201);

        $this->assertDatabaseHas('ratings', [
            'ride_id' => $rideId,
            'score' => 5,
        ]);
    }

    public function test_cannot_rate_a_ride_that_is_not_completed(): void
    {
        $rider = $this->makeRider();
        $rideId = $this->createRide($rider);

        Sanctum::actingAs($rider);
        $this->postJson("/api/rides/{$rideId}/rate", [
            'score' => 5,
        ])->assertStatus(422);
    }

    public function test_rider_cannot_access_driver_only_endpoint(): void
    {
        $rider = $this->makeRider();
        Sanctum::actingAs($rider);

        $this->getJson('/api/driver/rides/available')
            ->assertStatus(403);
    }
}
