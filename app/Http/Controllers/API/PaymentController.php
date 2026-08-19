<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\Ride;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Stripe\StripeClient;

class PaymentController extends Controller
{
    public function createCheckout(Request $request, $rideId): JsonResponse
    {
        try {
            $ride = Ride::findOrFail($rideId);

            if ($ride->rider_id !== auth()->id()) {
                return response()->json(['message' => 'Unauthorized'], 403);
            }

            if ($ride->status !== 'completed') {
                return response()->json([
                    'message' => 'Ride is not completed yet'
                ], 422);
            }

            if ($ride->transaction && $ride->transaction->payment_status === 'paid') {
                return response()->json([
                    'message' => 'This ride is already paid'
                ], 422);
            }

            $stripe = new StripeClient(config('services.stripe.secret'));

            $session = $stripe->checkout->sessions->create([
                'mode' => 'payment',
                'line_items' => [[
                    'price_data' => [
                        'currency' => 'usd',
                        'product_data' => [
                            'name' => 'RidePin trip #' . $ride->id,
                            'description' => $ride->pickup_location . ' to ' . $ride->dropoff_location,
                        ],
                        'unit_amount' => (int) round($ride->fare * 100),
                    ],
                    'quantity' => 1,
                ]],
                'metadata' => [
                    'ride_id' => $ride->id,
                    'rider_id' => $ride->rider_id,
                ],
                'success_url' => config('app.url') . '/payment-success?session_id={CHECKOUT_SESSION_ID}',
                'cancel_url' => config('app.url') . '/payment-cancel',
            ]);

            return response()->json([
                'checkout_url' => $session->url,
                'session_id' => $session->id,
            ]);
        } catch (\Throwable $e) {
            Log::error('Stripe checkout creation failed', [
                'ride_id' => $rideId,
                'error' => $e->getMessage(),
            ]);
            return response()->json([
                'message' => 'Could not start payment'
            ], 500);
        }
    }

    public function confirmCard(Request $request, $rideId): JsonResponse
    {
        $validated = $request->validate([
            'session_id' => ['required', 'string'],
        ]);

        try {
            $ride = Ride::findOrFail($rideId);

            if ($ride->rider_id !== auth()->id()) {
                return response()->json(['message' => 'Unauthorized'], 403);
            }

            $stripe = new StripeClient(config('services.stripe.secret'));
            $session = $stripe->checkout->sessions->retrieve($validated['session_id']);

            if ($session->payment_status !== 'paid') {
                return response()->json([
                    'message' => 'Payment not completed'
                ], 422);
            }

            $transaction = $ride->transaction;
            if ($transaction) {
                $transaction->update([
                    'payment_method' => 'card',
                    'payment_status' => 'paid',
                    'transaction_reference' => $session->payment_intent ?? $session->id,
                    'paid_at' => now(),
                ]);
            }

            return response()->json([
                'message' => 'Payment successful',
                'transaction' => $transaction ? $transaction->fresh() : null,
            ]);
        } catch (\Throwable $e) {
            Log::error('Stripe confirm failed', [
                'ride_id' => $rideId,
                'error' => $e->getMessage(),
            ]);
            return response()->json([
                'message' => 'Could not confirm payment'
            ], 500);
        }
    }

    public function payCash(Request $request, $rideId): JsonResponse
    {
        try {
            $ride = Ride::findOrFail($rideId);

            if ($ride->rider_id !== auth()->id()) {
                return response()->json(['message' => 'Unauthorized'], 403);
            }

            if ($ride->status !== 'completed') {
                return response()->json([
                    'message' => 'Ride is not completed yet'
                ], 422);
            }

            if (!$ride->transaction) {
                return response()->json([
                    'message' => 'No transaction for this ride'
                ], 422);
            }

            if ($ride->transaction->payment_status === 'paid') {
                return response()->json([
                    'message' => 'This ride is already paid'
                ], 422);
            }

            $ride->transaction->update([
                'payment_method' => 'cash',
                'payment_status' => 'paid',
                'paid_at' => now(),
            ]);

            return response()->json([
                'message' => 'Cash payment recorded',
                'transaction' => $ride->transaction->fresh(),
            ]);
        } catch (\Throwable $e) {
            Log::error('Cash payment failed', [
                'ride_id' => $rideId,
                'error' => $e->getMessage(),
            ]);
            return response()->json([
                'message' => 'Could not record payment'
            ], 500);
        }
    }
}
