<?php

namespace App\Http\Controllers\Api\V1\Auth;

use App\Http\Controllers\Controller;
use App\Http\Requests\Auth\SendOtpRequest;
use App\Http\Responses\ApiResponse;
use App\Services\Auth\OtpService;
use Illuminate\Http\JsonResponse;

class OtpController extends Controller
{
    public function send(SendOtpRequest $request, OtpService $otp): JsonResponse
    {
        $otp->send($request->validated('phone'), $request->ip());

        return ApiResponse::success([
            'expires_in' => $otp->ttlMinutes() * 60,
            'resend_after' => (int) config('insurance.otp.resend_after_seconds'),
        ], __('messages.otp.sent'));
    }
}
