<?php

namespace App\Http\Controllers\Api\V1\Auth;

use App\Http\Controllers\Controller;
use App\Http\Requests\Auth\RegisterRequest;
use App\Http\Requests\Auth\VerifyOtpRequest;
use App\Http\Resources\UserResource;
use App\Http\Responses\ApiResponse;
use App\Services\Auth\AuthService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AuthController extends Controller
{
    public function __construct(private readonly AuthService $auth) {}

    /**
     * Existing user → logged in. New phone → registration_token for /auth/register.
     */
    public function verifyOtp(VerifyOtpRequest $request): JsonResponse
    {
        $result = $this->auth->verifyOtp(
            $request->validated('phone'),
            $request->validated('code'),
            $request->validated('device_name'),
        );

        if ($result['is_new_user']) {
            return ApiResponse::success([
                'is_new_user' => true,
                'registration_token' => $result['registration_token'],
                'expires_in' => $result['expires_in'],
            ], __('messages.auth.complete_registration'));
        }

        return ApiResponse::success([
            'is_new_user' => false,
            'token' => $result['token'],
            'token_type' => 'Bearer',
            'user' => new UserResource($result['user']),
        ], __('messages.auth.logged_in'));
    }

    public function register(RegisterRequest $request): JsonResponse
    {
        $result = $this->auth->register(
            $request->safe()->only(['registration_token', 'name', 'national_id', 'device_name']),
            $request->file('id_image'),
            $request->file('license_image'),
        );

        return ApiResponse::created([
            'token' => $result['token'],
            'token_type' => 'Bearer',
            'user' => new UserResource($result['user']),
        ], __('messages.auth.registered'));
    }

    public function me(Request $request): JsonResponse
    {
        return ApiResponse::success(new UserResource($request->user()));
    }

    public function logout(Request $request): JsonResponse
    {
        $this->auth->logout($request->user());

        return ApiResponse::success(message: __('messages.auth.logged_out'));
    }
}
