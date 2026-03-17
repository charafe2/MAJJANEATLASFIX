<?php

use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\Storage;
use App\Http\Controllers\Auth\AuthController;

Route::get('/', function () {
    return view('welcome');
});

// Serve storage files with CORS headers (needed for Flutter web)
Route::get('storage/{path}', function (string $path) {
    $fullPath = storage_path("app/public/{$path}");
    if (!file_exists($fullPath)) {
        abort(404);
    }
    $mime = mime_content_type($fullPath) ?: 'application/octet-stream';
    return response()->file($fullPath, [
        'Access-Control-Allow-Origin' => '*',
        'Access-Control-Allow-Methods' => 'GET, OPTIONS',
        'Content-Type' => $mime,
    ]);
})->where('path', '.*');
Route::prefix('auth')->group(function () {
    Route::get('google',          [AuthController::class, 'googleRedirect']);
    Route::get('google/callback', [AuthController::class, 'googleCallback']);
});
