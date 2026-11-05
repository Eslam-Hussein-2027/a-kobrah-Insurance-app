<?php

use Illuminate\Support\Facades\Route;

// API-only backend. The admin dashboard (React) and mobile app (Flutter) consume /api/v1.
Route::get('/', fn () => response()->json([
    'name' => config('app.name'),
    'api' => url('/api/v1'),
    'health' => url('/up'),
]));
