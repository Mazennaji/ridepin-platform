<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreRatingRequest;
use App\Http\Requests\StoreRideRequest;
use App\Models\Rating;
use App\Models\Ride;
use App\Models\RideStatusLog;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Log;

class RideController extends Controller
{
    public function index(): JsonResponse
    {
        $user = auth()->user();

        if ($user->isRider()) {
            $rides = Ride::with(['rider', 'driver', 'transaction', 'rating', 'statusLogs'])
                ->where('rider_id', $user->id)
                ->latest()
                ->get();
        } elseif ($user->isDriver()) {
            $rides = Ride::with(['rider', 'driver', 'transaction', 'rating', 'statusLogs'])
                ->where('driver_id', $user->id)
                ->latest()
                ->get();
        } else {
            $rides = Ride::with(['rider', 'driver', 'transaction', 'rating', 'statusLogs'])
                ->latest()
                ->get();
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

            RideStatusLog::create([
                'ride_id' => $ride->id,
                'status' => 'pending',
                'changed_by' => auth()->id(),
                'timestamp' => now(),
            ]);

            return response()->json([
                'message' => 'Ride created successfully',
                'ride' => $ride->load(['rider', 'driver', 'statusLogs'])
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

            RideStatusLog::create([
                'ride_id' => $ride->id,
                'status' => 'cancelled',
                'changed_by' => auth()->id(),
                'timestamp' => now(),
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

    public function show($id): JsonResponse
    {
        $ride = Ride::with(['rider', 'driver', 'transaction', 'rating', 'statusLogs.changedBy'])->findOrFail($id);

        $this->authorize('view', $ride);

        return response()->json([
            'ride' => $ride
        ]);
    }

    public function rate(StoreRatingRequest $request, $id): JsonResponse
    {
        try {
            $ride = Ride::findOrFail($id);

            if ($ride->rider_id !== auth()->id()) {
                return response()->json([
                    'message' => 'Unauthorized'
                ], 403);
            }

            if ($ride->status !== 'completed') {
                return response()->json([
                    'message' => 'You can only rate completed rides'
                ], 422);
            }

            if ($ride->rating) {
                return response()->json([
                    'message' => 'This ride has already been rated'
                ], 422);
            }

            $rating = Rating::create([
                'ride_id' => $ride->id,
                'rider_id' => auth()->id(),
                'driver_id' => $ride->driver_id,
                'score' => $request->score,
                'comment' => $request->comment,
            ]);

            return response()->json([
                'message' => 'Rating submitted successfully',
                'rating' => $rating
            ], 201);
        } catch (\Throwable $e) {
            Log::error('Ride rating failed', [
                'ride_id' => $id,
                'user_id' => auth()->id(),
                'error' => $e->getMessage()
            ]);

            return response()->json([
                'message' => 'Ride rating failed'
            ], 500);
        }
    }
}
