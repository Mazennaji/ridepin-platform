<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\Ride;
use App\Models\Transaction;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;
use Stripe\StripeClient;

class PaymentController extends Controller
{
    public function createIntent(Request $request, $rideId): JsonResponse
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

            $intent = $stripe->paymentIntents->create([
                'amount' => (int) round($ride->fare * 100), // cents
                'currency' => 'usd',
                'metadata' => [
                    'ride_id' => $ride->id,
                    'rider_id' => $ride->rider_id,
                ],
                'automatic_payment_methods' => ['enabled' => true],
            ]);

            return response()->json([
                'client_secret' => $intent->client_secret,
                'publishable_key' => config('services.stripe.publishable'),
                'amount' => $ride->fare,
            ]);
        } catch (\Throwable $e) {
            Log::error('Stripe intent creation failed', [
                'ride_id' => $rideId,
                'error' => $e->getMessage(),
            ]);
            return response()->json([
                'message' => 'Could not start payment'
            ], 500);
        }
    }

    public function confirm(Request $request, $rideId): JsonResponse
    {
        $validated = $request->validate([
            'payment_intent_id' => ['required', 'string'],
        ]);

        try {
            $ride = Ride::findOrFail($rideId);

            if ($ride->rider_id !== auth()->id()) {
                return response()->json(['message' => 'Unauthorized'], 403);
            }

            $stripe = new StripeClient(config('services.stripe.secret'));
            $intent = $stripe->paymentIntents->retrieve($validated['payment_intent_id']);

            if ($intent->status !== 'succeeded') {
                return response()->json([
                    'message' => 'Payment not completed'
                ], 422);
            }

            $transaction = Transaction::updateOrCreate(
                ['ride_id' => $ride->id],
                [
                    'user_id' => $ride->rider_id,
                    'amount' => $ride->fare,
                    'payment_method' => 'card',
                    'payment_status' => 'paid',
                    'transaction_reference' => $intent->id,
                    'paid_at' => now(),
                ]
            );

            return response()->json([
                'message' => 'Payment successful',
                'transaction' => $transaction,
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
}
