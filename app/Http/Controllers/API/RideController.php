<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreRatingRequest;
use App\Http\Requests\StoreRideRequest;
use App\Models\Rating;
use App\Models\Ride;
use App\Models\RideStatusLog;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class RideController extends Controller
{
    private const BASE_FARE = 2.50;
    private const PER_KM_RATE = 1.50;

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

    public function estimate(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'pickup_latitude' => ['required', 'numeric'],
            'pickup_longitude' => ['required', 'numeric'],
            'dropoff_latitude' => ['required', 'numeric'],
            'dropoff_longitude' => ['required', 'numeric'],
        ]);

        $distance = $this->haversineDistance(
            (float) $validated['pickup_latitude'],
            (float) $validated['pickup_longitude'],
            (float) $validated['dropoff_latitude'],
            (float) $validated['dropoff_longitude'],
        );

        return response()->json([
            'distance' => $distance,
            'fare' => $this->calculateFare($distance),
        ]);
    }

    public function store(StoreRideRequest $request): JsonResponse
    {
        try {
            $this->authorize('create', Ride::class);

            $distance = $this->haversineDistance(
                (float) $request->pickup_latitude,
                (float) $request->pickup_longitude,
                (float) $request->dropoff_latitude,
                (float) $request->dropoff_longitude,
            );

            $fare = $this->calculateFare($distance);

            $ride = DB::transaction(function () use ($request, $distance, $fare) {
                $ride = Ride::create([
                    'rider_id' => auth()->id(),
                    'pickup_location' => $request->pickup_location,
                    'dropoff_location' => $request->dropoff_location,
                    'pickup_latitude' => $request->pickup_latitude,
                    'pickup_longitude' => $request->pickup_longitude,
                    'dropoff_latitude' => $request->dropoff_latitude,
                    'dropoff_longitude' => $request->dropoff_longitude,
                    'fare' => $fare,
                    'distance' => $distance,
                    'status' => 'pending',
                ]);

                RideStatusLog::create([
                    'ride_id' => $ride->id,
                    'status' => 'pending',
                    'changed_by' => auth()->id(),
                    'timestamp' => now(),
                ]);

                return $ride;
            });

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

            DB::transaction(function () use ($ride) {
                $ride->update([
                    'status' => 'cancelled'
                ]);

                RideStatusLog::create([
                    'ride_id' => $ride->id,
                    'status' => 'cancelled',
                    'changed_by' => auth()->id(),
                    'timestamp' => now(),
                ]);
            });

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

    private function calculateFare(float $distanceKm): float
    {
        return round(self::BASE_FARE + ($distanceKm * self::PER_KM_RATE), 2);
    }

    private function haversineDistance(
        float $lat1,
        float $lon1,
        float $lat2,
        float $lon2
    ): float {
        $earthRadius = 6371;
        $dLat = deg2rad($lat2 - $lat1);
        $dLon = deg2rad($lon2 - $lon1);
        $a = sin($dLat / 2) * sin($dLat / 2) +
            cos(deg2rad($lat1)) * cos(deg2rad($lat2)) *
            sin($dLon / 2) * sin($dLon / 2);
        $c = 2 * atan2(sqrt($a), sqrt(1 - $a));

        return round($earthRadius * $c, 2);
    }
}
