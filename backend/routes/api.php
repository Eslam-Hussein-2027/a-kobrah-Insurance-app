<?php

use App\Enums\UserDocumentType;
use App\Enums\UserRole;
use App\Http\Controllers\Api\V1\Admin\CustomerController as AdminCustomerController;
use App\Http\Controllers\Api\V1\Admin\DashboardController;
use App\Http\Controllers\Api\V1\Admin\PaymentController as AdminPaymentController;
use App\Http\Controllers\Api\V1\Admin\PolicyController as AdminPolicyController;
use App\Http\Controllers\Api\V1\Admin\PolicyPaymentController;
use App\Http\Controllers\Api\V1\Admin\PricingController;
use App\Http\Controllers\Api\V1\Auth\AuthController;
use App\Http\Controllers\Api\V1\Auth\OtpController;
use App\Http\Controllers\Api\V1\CoverageTypeController;
use App\Http\Controllers\Api\V1\FileController;
use App\Http\Controllers\Api\V1\PaymentController;
use App\Http\Controllers\Api\V1\PaymentWebhookController;
use App\Http\Controllers\Api\V1\PolicyController;
use App\Http\Controllers\Api\V1\PolicyVerificationController;
use App\Http\Controllers\Api\V1\ProfileController;
use App\Http\Controllers\Api\V1\QuoteController;
use App\Http\Controllers\Api\V1\VehicleController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API v1  (prefix: /api/v1, name: api.v1.*)
|--------------------------------------------------------------------------
*/

Route::prefix('v1')->name('api.v1.')->group(function () {

    // ------------------------------------------------------------ Public

    Route::prefix('auth')->name('auth.')->group(function () {
        Route::post('otp/send', [OtpController::class, 'send'])->middleware('throttle:otp')->name('otp.send');
        Route::post('otp/verify', [AuthController::class, 'verifyOtp'])->middleware('throttle:auth')->name('otp.verify');
        Route::post('register', [AuthController::class, 'register'])->middleware('throttle:auth')->name('register');
        // Dashboard login (admin / surveyor / workshop).
        Route::post('staff/login', [AuthController::class, 'staffLogin'])->middleware('throttle:auth')->name('staff.login');
    });

    Route::get('coverage-types', [CoverageTypeController::class, 'index'])->name('coverage-types.index');

    Route::get('policies/verify', PolicyVerificationController::class)
        ->middleware('throttle:policy-verification')
        ->name('policies.verify');

    // Server-to-server notifications from payment providers.
    Route::post('payments/webhook/{gateway}', PaymentWebhookController::class)
        ->middleware('throttle:webhooks')
        ->name('payments.webhook');

    // Private files: access is granted by the temporary URL signature.
    Route::get('files/users/{user}/{type}', [FileController::class, 'userDocument'])
        ->whereIn('type', UserDocumentType::values())
        ->middleware('signed')
        ->name('files.user-document');

    // ------------------------------------------------------------ Authenticated

    Route::middleware(['auth:sanctum', 'throttle:api'])->group(function () {

        Route::get('auth/me', [AuthController::class, 'me'])->name('auth.me');
        Route::post('auth/logout', [AuthController::class, 'logout'])->name('auth.logout');

        // Customer app
        Route::middleware('role:'.UserRole::Customer->value)->group(function () {
            Route::post('me/documents', [ProfileController::class, 'uploadDocuments'])->name('me.documents');

            Route::apiResource('vehicles', VehicleController::class);

            Route::post('quotes', [QuoteController::class, 'store'])->name('quotes.store');

            Route::get('policies', [PolicyController::class, 'index'])->name('policies.index');
            Route::post('policies', [PolicyController::class, 'store'])->name('policies.store');
            Route::get('policies/{policy}', [PolicyController::class, 'show'])->whereNumber('policy')->name('policies.show');
            Route::post('policies/{policy}/cancel', [PolicyController::class, 'cancel'])->whereNumber('policy')->name('policies.cancel');
            Route::get('policies/{policy}/pdf', [PolicyController::class, 'downloadPdf'])->whereNumber('policy')->name('policies.pdf');

            Route::post('policies/{policy}/pay-online', [PaymentController::class, 'payOnline'])->whereNumber('policy')->name('policies.pay-online');
            Route::get('payments/{payment}', [PaymentController::class, 'show'])->whereNumber('payment')->name('payments.show');
        });

        // Admin dashboard
        Route::prefix('admin')->name('admin.')->middleware('role:'.UserRole::Admin->value)->group(function () {
            Route::get('stats', DashboardController::class)->name('stats');

            Route::get('policies', [AdminPolicyController::class, 'index'])->name('policies.index');
            Route::get('policies/{policy}', [AdminPolicyController::class, 'show'])->whereNumber('policy')->name('policies.show');
            Route::post('policies/{policy}/cancel', [AdminPolicyController::class, 'cancel'])->whereNumber('policy')->name('policies.cancel');
            Route::get('policies/{policy}/pdf', [AdminPolicyController::class, 'pdf'])->whereNumber('policy')->name('policies.pdf');
            Route::post('policies/{policy}/confirm-office-payment', [PolicyPaymentController::class, 'confirmOffice'])
                ->whereNumber('policy')
                ->name('policies.confirm-office-payment');

            Route::get('payments', [AdminPaymentController::class, 'index'])->name('payments.index');

            Route::get('customers', [AdminCustomerController::class, 'index'])->name('customers.index');
            Route::get('customers/{customer}', [AdminCustomerController::class, 'show'])->whereNumber('customer')->name('customers.show');
            Route::patch('customers/{customer}', [AdminCustomerController::class, 'update'])->whereNumber('customer')->name('customers.update');

            Route::get('pricing', [PricingController::class, 'index'])->name('pricing.index');
            Route::patch('coverage-types/{coverageType}', [PricingController::class, 'updateCoverageType'])->name('coverage-types.update');
            Route::post('pricing-factors', [PricingController::class, 'storeFactor'])->name('pricing-factors.store');
            Route::put('pricing-factors/{pricingFactor}', [PricingController::class, 'updateFactor'])->name('pricing-factors.update');
            Route::delete('pricing-factors/{pricingFactor}', [PricingController::class, 'destroyFactor'])->name('pricing-factors.destroy');
        });
    });
});
