<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Http\Requests\LoginRequest;
use App\Http\Requests\RegisterRequest;
use App\Models\DriverProfile;
use App\Models\Role;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Log;

class AuthController extends Controller
{
    public function register(RegisterRequest $request): JsonResponse
    {
        try {
            $role = Role::where('name', $request->role)->first();

            if (!$role) {
                return response()->json([
                    'message' => 'Role not found',
                ], 422);
            }

            $user = User::create([
                'name' => $request->name,
                'email' => $request->email,
                'phone' => $request->phone,
                'password' => Hash::make($request->password),
                'role_id' => $role->id,
            ]);

            if ($request->role === 'driver') {
                DriverProfile::create([
                    'user_id' => $user->id,
                    'license_number' => 'PENDING',
                    'vehicle_type' => 'PENDING',
                    'vehicle_model' => 'PENDING',
                    'plate_number' => 'PENDING',
                    'is_available' => false,
                    'verification_status' => false,
                ]);
            }

            $token = $user->createToken('api-token')->plainTextToken;

            return response()->json([
                'message' => 'User registered successfully',
                'token' => $token,
                'user' => $user->load('role', 'driverProfile'),
            ], 201);
        } catch (\Throwable $e) {
            Log::error('Registration failed', [
                'error' => $e->getMessage(),
            ]);

            return response()->json([
                'message' => 'Registration failed',
            ], 500);
        }
    }

    public function login(LoginRequest $request): JsonResponse
    {
        try {
            $user = User::where('email', $request->email)->first();

            if (!$user || !Hash::check($request->password, $user->password)) {
                return response()->json([
                    'message' => 'Invalid credentials',
                ], 401);
            }

            $token = $user->createToken('api-token')->plainTextToken;

            return response()->json([
                'message' => 'Login successful',
                'token' => $token,
                'user' => $user->load('role', 'driverProfile'),
            ]);
        } catch (\Throwable $e) {
            Log::error('Login failed', [
                'error' => $e->getMessage(),
            ]);

            return response()->json([
                'message' => 'Login failed',
            ], 500);
        }
    }

    public function profile(): JsonResponse
    {
        return response()->json([
            'user' => auth()->user()->load('role', 'driverProfile'),
        ]);
    }

    public function logout(): JsonResponse
    {
        $user = auth()->user();

        if ($user) {
            $user->tokens()->delete();
        }

        return response()->json([
            'message' => 'Logged out successfully',
        ]);
    }
}
