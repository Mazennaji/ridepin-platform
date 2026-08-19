<?php

use App\Http\Controllers\API\AuthController;
use App\Http\Controllers\API\DriverController;
use App\Http\Controllers\API\RideController;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\API\PaymentController;

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

Route::middleware('auth:sanctum')->group(function () {
    Route::get('/profile', [AuthController::class, 'profile']);
    Route::post('/logout', [AuthController::class, 'logout']);

    Route::get('/rides', [RideController::class, 'index']);
    Route::get('/rides/{id}', [RideController::class, 'show']);
    Route::post('/rides', [RideController::class, 'store']);
    Route::post('/rides/{id}/cancel', [RideController::class, 'cancel']);
    Route::post('/rides/{id}/rate', [RideController::class, 'rate']);

    Route::get('/driver/rides/available', [DriverController::class, 'available']);
    Route::post('/driver/rides/{id}/accept', [DriverController::class, 'accept']);
    Route::post('/driver/rides/{id}/start', [DriverController::class, 'start']);
    Route::post('/driver/rides/{id}/complete', [DriverController::class, 'complete']);
    Route::post('/driver/toggle-availability', [DriverController::class, 'toggleAvailability']);
    Route::post('/rides/estimate', [RideController::class, 'estimate']);
    Route::post('/rides/{id}/payment/intent', [PaymentController::class, 'createIntent']);
    Route::post('/rides/{id}/payment/confirm', [PaymentController::class, 'confirm']);

    Route::post('/rides/{id}/payment/intent', [PaymentController::class, 'createIntent']);
    Route::post('/rides/{id}/payment/card', [PaymentController::class, 'confirmCard']);
    Route::post('/rides/{id}/payment/cash', [PaymentController::class, 'payCash']);
});
