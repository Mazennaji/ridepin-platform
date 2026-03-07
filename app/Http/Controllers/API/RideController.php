<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreRideRequest;
use App\Models\Ride;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Log;

class RideController extends Controller
{
    public function index(): JsonResponse
    {
        $user = auth()->user();

        if ($user->isRider()) {
            $rides = Ride::with(['rider', 'driver'])
                ->where('rider_id', $user->id)
                ->latest()
                ->get();
        } elseif ($user->isDriver()) {
            $rides = Ride::with(['rider', 'driver'])
                ->where('driver_id', $user->id)
                ->latest()
                ->get();
        } else {
            $rides = Ride::with(['rider', 'driver'])->latest()->get();
        }

        return response()->json([
            'rides' => $rides
        ]);
    }

    public function store(StoreRideRequest $request): JsonResponse
    {
        try {
            $this->authorize('create', Ride::class);

            $ride = Ride::create([
                'rider_id' => auth()->id(),
                'pickup_location' => $request->pickup_location,
                'dropoff_location' => $request->dropoff_location,
                'pickup_latitude' => $request->pickup_latitude,
                'pickup_longitude' => $request->pickup_longitude,
                'dropoff_latitude' => $request->dropoff_latitude,
                'dropoff_longitude' => $request->dropoff_longitude,
                'fare' => 10.00,
                'distance' => 5.00,
                'status' => 'pending',
            ]);

            return response()->json([
                'message' => 'Ride created successfully',
                'ride' => $ride
            ], 201);
        } catch (\Throwable $e) {
            Log::error('Ride creation failed', [
                'user_id' => auth()->id(),
                'error' => $e->getMessage()
            ]);

            return response()->json([
                'message' => 'Ride creation failed'
            ], 500);
        }
    }

    public function cancel($id): JsonResponse
    {
        try {
            $ride = Ride::findOrFail($id);

            $this->authorize('cancel', $ride);

            $ride->update([
                'status' => 'cancelled'
            ]);

            return response()->json([
                'message' => 'Ride cancelled successfully',
                'ride' => $ride
            ]);
        } catch (\Throwable $e) {
            Log::error('Ride cancellation failed', [
                'ride_id' => $id,
                'user_id' => auth()->id(),
                'error' => $e->getMessage()
            ]);

            return response()->json([
                'message' => 'Ride cancellation failed'
            ], 500);
        }
    }
}
