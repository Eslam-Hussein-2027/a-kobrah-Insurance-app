<?php

use App\Http\Controllers\Web\PaymentPageController;
use Illuminate\Support\Facades\Route;

// API-only backend. The admin dashboard (React) and mobile app (Flutter) consume /api/v1.
Route::get('/', fn () => response()->json([
    'name' => config('app.name'),
    'api' => url('/api/v1'),
    'health' => url('/up'),
]));

// Browser pages for online payment (signed links only).
Route::middleware('signed')->prefix('payments')->name('payments.')->group(function () {
    Route::get('simulator/{payment}', [PaymentPageController::class, 'simulator'])->name('simulator.show');
    Route::post('simulator/{payment}', [PaymentPageController::class, 'completeSimulator'])->name('simulator.complete');
    Route::get('{payment}/result', [PaymentPageController::class, 'result'])->name('result');
});
