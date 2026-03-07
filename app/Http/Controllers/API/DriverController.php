<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\Ride;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

class DriverController extends Controller
{
    public function available(): JsonResponse
    {
        $user = auth()->user();

        if (!$user->isDriver()) {
            return response()->json([
                'message' => 'Unauthorized'
            ], 403);
        }

        $rides = Ride::with('rider')
            ->where('status', 'pending')
            ->latest()
            ->get();

        return response()->json([
            'rides' => $rides
        ]);
    }

    public function accept($id): JsonResponse
    {
        try {
            $user = auth()->user();

            $ride = Ride::findOrFail($id);

            $this->authorize('accept', $ride);

            $ride->update([
                'driver_id' => $user->id,
                'status' => 'accepted',
            ]);

            return response()->json([
                'message' => 'Ride accepted successfully',
                'ride' => $ride->load('rider', 'driver')
            ]);
        } catch (\Throwable $e) {
            Log::error('Ride accept failed', [
                'ride_id' => $id,
                'driver_id' => auth()->id(),
                'error' => $e->getMessage()
            ]);

            return response()->json([
                'message' => 'Ride accept failed'
            ], 500);
        }
    }

    public function start($id): JsonResponse
    {
        try {
            $ride = Ride::findOrFail($id);

            $this->authorize('start', $ride);

            $ride->update([
                'status' => 'started',
            ]);

            return response()->json([
                'message' => 'Ride started successfully',
                'ride' => $ride
            ]);
        } catch (\Throwable $e) {
            Log::error('Ride start failed', [
                'ride_id' => $id,
                'driver_id' => auth()->id(),
                'error' => $e->getMessage()
            ]);

            return response()->json([
                'message' => 'Ride start failed'
            ], 500);
        }
    }

    public function complete($id): JsonResponse
    {
        try {
            $ride = Ride::findOrFail($id);

            $this->authorize('complete', $ride);

            $ride->update([
                'status' => 'completed',
            ]);

            return response()->json([
                'message' => 'Ride completed successfully',
                'ride' => $ride
            ]);
        } catch (\Throwable $e) {
            Log::error('Ride completion failed', [
                'ride_id' => $id,
                'driver_id' => auth()->id(),
                'error' => $e->getMessage()
            ]);

            return response()->json([
                'message' => 'Ride completion failed'
            ], 500);
        }
    }

    public function toggleAvailability(Request $request): JsonResponse
    {
        $request->validate([
            'is_available' => ['required', 'boolean']
        ]);

        $user = auth()->user();

        if (!$user->isDriver() || !$user->driverProfile) {
            return response()->json([
                'message' => 'Driver profile not found'
            ], 404);
        }

        $user->driverProfile->update([
            'is_available' => $request->is_available
        ]);

        return response()->json([
            'message' => 'Availability updated successfully',
            'driver_profile' => $user->driverProfile
        ]);
    }
}
