<?php

namespace Tests\Feature;

use App\Models\Role;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

class AuthTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        Role::firstOrCreate(['name' => 'admin']);
        Role::firstOrCreate(['name' => 'rider']);
        Role::firstOrCreate(['name' => 'driver']);
    }

    public function test_a_rider_can_register_and_receive_a_token(): void
    {
        $response = $this->postJson('/api/register', [
            'name' => 'Test Rider',
            'email' => 'newrider@ridepin.com',
            'password' => 'password123',
            'password_confirmation' => 'password123',
            'role' => 'rider',
        ]);

        $response->assertStatus(201)
            ->assertJsonStructure(['token', 'user' => ['id', 'email', 'role']]);

        $this->assertDatabaseHas('users', ['email' => 'newrider@ridepin.com']);
    }

    public function test_registering_as_driver_creates_a_driver_profile(): void
    {
        $response = $this->postJson('/api/register', [
            'name' => 'Test Driver',
            'email' => 'newdriver@ridepin.com',
            'password' => 'password123',
            'password_confirmation' => 'password123',
            'role' => 'driver',
        ]);

        $response->assertStatus(201);

        $user = User::where('email', 'newdriver@ridepin.com')->first();
        $this->assertDatabaseHas('driver_profiles', ['user_id' => $user->id]);
    }

    public function test_a_user_can_login_with_valid_credentials(): void
    {
        $rider = Role::where('name', 'rider')->first();
        User::create([
            'name' => 'Login User',
            'email' => 'login@ridepin.com',
            'password' => Hash::make('password123'),
            'role_id' => $rider->id,
        ]);

        $response = $this->postJson('/api/login', [
            'email' => 'login@ridepin.com',
            'password' => 'password123',
        ]);

        $response->assertStatus(200)->assertJsonStructure(['token']);
    }

    public function test_login_fails_with_invalid_credentials(): void
    {
        $rider = Role::where('name', 'rider')->first();
        User::create([
            'name' => 'Login User',
            'email' => 'login2@ridepin.com',
            'password' => Hash::make('password123'),
            'role_id' => $rider->id,
        ]);

        $response = $this->postJson('/api/login', [
            'email' => 'login2@ridepin.com',
            'password' => 'wrongpassword',
        ]);

        $response->assertStatus(401);
    }

    public function test_protected_route_requires_authentication(): void
    {
        $response = $this->getJson('/api/profile');
        $response->assertStatus(401);
    }
}
