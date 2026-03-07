<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "api" middleware group. Make something great!
|
*/

use App\Http\Controllers\API\AuthController;
use App\Http\Controllers\API\RideController;
use App\Http\Controllers\API\DriverController;

Route::post('/register',[AuthController::class,'register']);
Route::post('/login',[AuthController::class,'login']);

Route::middleware('auth:sanctum')->group(function(){

    Route::get('/profile',[AuthController::class,'profile']);

    Route::post('/rides',[RideController::class,'store']);
    Route::get('/rides',[RideController::class,'index']);
    Route::post('/rides/{id}/cancel',[RideController::class,'cancel']);

    Route::get('/driver/rides/available',[DriverController::class,'available']);
    Route::post('/driver/rides/{id}/accept',[DriverController::class,'accept']);
    Route::post('/driver/rides/{id}/start',[DriverController::class,'start']);
    Route::post('/driver/rides/{id}/complete',[DriverController::class,'complete']);
});
