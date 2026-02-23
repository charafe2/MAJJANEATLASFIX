<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Auth\AuthController;
use App\Http\Controllers\Client\ServiceRequestController;
use App\Http\Controllers\Artisan\ServiceRequestController as ArtisanServiceRequestController;
use App\Http\Controllers\Messaging\ConversationController;
use App\Http\Controllers\Messaging\MessageController;
use App\Http\Controllers\AgendaController;
use App\Http\Controllers\PaymentStatsController;
use App\Http\Controllers\ArtisanBrowseController;
use App\Http\Controllers\NotificationController;

/*
|--------------------------------------------------------------------------
| Public browse routes (no auth required)
|--------------------------------------------------------------------------
*/
Route::get('public/categories',    [ArtisanBrowseController::class, 'categories']);
Route::get('public/artisans',      [ArtisanBrowseController::class, 'artisans']);
Route::get('referral/{code}',      [AuthController::class, 'validateReferral']);

/*
|--------------------------------------------------------------------------
| Auth routes (PUBLIC)
|--------------------------------------------------------------------------
*/
Route::post('pre-register',      [AuthController::class, 'preRegister']);
Route::post('verify',            [AuthController::class, 'verify']);
Route::post('complete-register', [AuthController::class, 'completeRegister']);
Route::post('/register',         [AuthController::class, 'register']);
Route::post('resend',            [AuthController::class, 'resendCode']);
Route::post('login',             [AuthController::class, 'login']);
Route::post('forgot-password',   [AuthController::class, 'forgotPassword']);
Route::post('reset-password',    [AuthController::class, 'resetPassword']);

// ── Google OAuth ──────────────────────────────────────────────────────────
Route::post('google/complete',   [AuthController::class, 'googleComplete']);
Route::post('complete-plan',     [AuthController::class, 'completePlan']);

/*
|--------------------------------------------------------------------------
| Authenticated routes
|--------------------------------------------------------------------------
*/
Route::middleware('auth:sanctum')->group(function () {
    Route::post ('logout', [AuthController::class, 'logout']);
    Route::get  ('me',     [AuthController::class, 'me']);
    Route::post ('me',     [AuthController::class, 'updateMe']);

    // ── Service categories & types ────────────────────────────────────────
    Route::get('categories',                          [ServiceRequestController::class, 'getCategories']);
    Route::get('categories/{category}/service-types', [ServiceRequestController::class, 'getServiceTypes']);

    // ── Client endpoints ──────────────────────────────────────────────────
    Route::prefix('client')->group(function () {
        Route::get   ('service-requests',                                        [ServiceRequestController::class, 'index']);
        Route::post  ('service-requests',                                        [ServiceRequestController::class, 'store']);
        Route::get   ('service-requests/{serviceRequest}',                       [ServiceRequestController::class, 'show']);
        Route::patch ('service-requests/{serviceRequest}/cancel',                [ServiceRequestController::class, 'cancel']);
        Route::post  ('service-requests/{serviceRequest}/offers/{offer}/accept', [ServiceRequestController::class, 'acceptOffer']);
        Route::post  ('service-requests/{serviceRequest}/offers/{offer}/reject', [ServiceRequestController::class, 'rejectOffer']);
    });

    // ── Artisan endpoints ─────────────────────────────────────────────────
    Route::prefix('artisan')->group(function () {
        Route::post  ('service',                                  [AuthController::class, 'addService']);
        Route::delete('portfolio/{photo}',                        [AuthController::class, 'deletePortfolioPhoto']);
        Route::post  ('boost/activate',                           [AuthController::class, 'activateBoost']);
        Route::get  ('service-requests',                         [ArtisanServiceRequestController::class, 'index']);
        Route::get  ('service-requests/{serviceRequest}',        [ArtisanServiceRequestController::class, 'show']);
        Route::post ('service-requests/{serviceRequest}/offers', [ArtisanServiceRequestController::class, 'submitOffer']);
        Route::get  ('offers',                                   [ArtisanServiceRequestController::class, 'myOffers']);
        Route::get  ('clients/{client}',                         [ArtisanServiceRequestController::class, 'clientProfile']);
    });

    // ── Agenda endpoints ──────────────────────────────────────────────────
    Route::get ('agenda', [AgendaController::class, 'index']);
    Route::post('agenda', [AgendaController::class, 'store']);

    // ── Payment stats endpoint ────────────────────────────────────────────
    Route::get('payment-stats', [PaymentStatsController::class, 'index']);

    // ── Notification endpoints ────────────────────────────────────────────
    Route::get  ('notifications',              [NotificationController::class, 'index']);
    Route::patch('notifications/read-all',     [NotificationController::class, 'markAllRead']);
    Route::patch('notifications/{notification}/read', [NotificationController::class, 'markRead']);

    // ── Messaging endpoints ───────────────────────────────────────────────
    Route::prefix('conversations')->group(function () {
        Route::get  ('',                        [ConversationController::class, 'index']);
        Route::post ('',                        [ConversationController::class, 'store']);
        Route::get  ('{conversation}',          [ConversationController::class, 'show']);
        Route::get  ('{conversation}/messages', [MessageController::class, 'index']);
        Route::post ('{conversation}/messages', [MessageController::class, 'store']);
        Route::post ('{conversation}/read',     [MessageController::class, 'markRead']);
    });
});
