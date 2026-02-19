<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Auth\AuthController;
use App\Http\Controllers\Client\ServiceRequestController;
use App\Http\Controllers\Artisan\ServiceRequestController as ArtisanServiceRequestController;

/*
|--------------------------------------------------------------------------
| Auth routes
|--------------------------------------------------------------------------
*/
    // Step 1: create stub user + fire OTP
    Route::post('pre-register',      [AuthController::class, 'preRegister']);
    // Step 2: verify the OTP code (existing endpoint, no change)
    Route::post('verify',            [AuthController::class, 'verify']);
    // Step 3: set password + all profile fields → returns token
    Route::post('complete-register', [AuthController::class, 'completeRegister']);

    //Standard / web registration (kept for backward compat) ───────────
    Route::post('/register',          [AuthController::class, 'register']);

    Route::post('resend',            [AuthController::class, 'resendCode']);
    Route::post('login',             [AuthController::class, 'login']);
    Route::post('forgot-password',   [AuthController::class, 'forgotPassword']);
    Route::post('reset-password',    [AuthController::class, 'resetPassword']);

    // ── Google OAuth ─────────────────────────────────────────────────────
    // Route::get ('google',            [AuthController::class, 'googleRedirect']);
    // Route::get ('google/callback',   [AuthController::class, 'googleCallback']);
    Route::post('google/complete',   [AuthController::class, 'googleComplete']);
        Route::post('complete-plan', [AuthController::class, 'completePlan']);
Route::post('complete-plan', [AuthController::class, 'completePlan']);

    // ── Authenticated ─────────────────────────────────────────────────────
    Route::middleware('auth:sanctum')->group(function () {
        Route::post('logout',        [AuthController::class, 'logout']);
        Route::get ('me',            [AuthController::class, 'me']);

        // ── Service categories & types (public read — available to all auth users)
        Route::get('categories',                              [ServiceRequestController::class, 'getCategories']);
        Route::get('categories/{category}/service-types',    [ServiceRequestController::class, 'getServiceTypes']);

        // ── Client: Nouvelle demande flow ─────────────────────────────────
        Route::prefix('client')->group(function () {
            Route::get   ('service-requests',                [ServiceRequestController::class, 'index']);
            Route::post  ('service-requests',                [ServiceRequestController::class, 'store']);
            Route::get   ('service-requests/{serviceRequest}', [ServiceRequestController::class, 'show']);
            Route::patch ('service-requests/{serviceRequest}/cancel',              [ServiceRequestController::class, 'cancel']);
            Route::post  ('service-requests/{serviceRequest}/offers/{offer}/accept', [ServiceRequestController::class, 'acceptOffer']);
            Route::post  ('service-requests/{serviceRequest}/offers/{offer}/reject', [ServiceRequestController::class, 'rejectOffer']);
        });

        // ── Artisan: Browse & respond to client requests ───────────────────
        Route::prefix('artisan')->group(function () {
            Route::get  ('service-requests',                          [ArtisanServiceRequestController::class, 'index']);
            Route::post ('service-requests/{serviceRequest}/offers',  [ArtisanServiceRequestController::class, 'submitOffer']);
            Route::get  ('offers',                                    [ArtisanServiceRequestController::class, 'myOffers']);
            Route::get  ('clients/{client}',                          [ArtisanServiceRequestController::class, 'clientProfile']);
        });
    });
;