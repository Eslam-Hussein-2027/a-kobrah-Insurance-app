<?php

namespace App\Http\Controllers\Api\V1\Auth;

use App\Http\Controllers\Controller;
use App\Http\Requests\Auth\ChangePasswordRequest;
use App\Http\Requests\Auth\ForgotPasswordRequest;
use App\Http\Requests\Auth\LoginRequest;
use App\Http\Requests\Auth\RegisterRequest;
use App\Http\Requests\Auth\ResetPasswordRequest;
use App\Http\Resources\UserResource;
use App\Http\Responses\ApiResponse;
use App\Models\User;
use App\Services\Auth\AuthService;
use App\Services\Auth\OtpService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AuthController extends Controller
{
    public function __construct(private readonly AuthService $auth) {}

    /**
     * 202 + verification_required when an SMS code was sent (call again with "code"),
     * 201 + token once the account exists.
     */
    public function register(RegisterRequest $request): JsonResponse
    {
        $result = $this->auth->register(
            $request->safe()->only(['first_name', 'last_name', 'phone', 'address', 'password', 'device_name']),
            $request->validated('code'),
            $request->ip(),
        );

        if ($result['verification_required']) {
            return ApiResponse::success([
                'verification_required' => true,
                'expires_in' => $result['expires_in'],
                'resend_after' => $result['resend_after'],
            ], __('messages.otp.sent'), 202);
        }

        return ApiResponse::created($this->session($result['token'], $result['user']), __('messages.auth.registered'));
    }

    public function login(LoginRequest $request): JsonResponse
    {
        $result = $this->auth->login(
            $request->validated('phone'),
            $request->validated('password'),
            $request->validated('device_name'),
        );

        return ApiResponse::success($this->session($result['token'], $result['user']), __('messages.auth.logged_in'));
    }

    public function forgotPassword(ForgotPasswordRequest $request, OtpService $otp): JsonResponse
    {
        $this->auth->sendPasswordResetCode($request->validated('phone'), $request->ip());

        return ApiResponse::success([
            'expires_in' => $otp->ttlMinutes() * 60,
            'resend_after' => $otp->resendAfterSeconds(),
        ], __('messages.auth.reset_code_sent'));
    }

    public function resetPassword(ResetPasswordRequest $request): JsonResponse
    {
        $result = $this->auth->resetPassword(
            $request->validated('phone'),
            $request->validated('code'),
            $request->validated('password'),
            $request->validated('device_name'),
        );

        return ApiResponse::success($this->session($result['token'], $result['user']), __('messages.auth.password_reset'));
    }

    public function changePassword(ChangePasswordRequest $request): JsonResponse
    {
        $this->auth->changePassword(
            $request->user(),
            $request->validated('current_password'),
            $request->validated('password'),
        );

        return ApiResponse::success(message: __('messages.auth.password_changed'));
    }

    public function staffLogin(LoginRequest $request): JsonResponse
    {
        $result = $this->auth->staffLogin(
            $request->validated('phone'),
            $request->validated('password'),
            $request->validated('device_name'),
        );

        return ApiResponse::success($this->session($result['token'], $result['user']), __('messages.auth.logged_in'));
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

    /**
     * @return array{token: string, token_type: string, user: UserResource}
     */
    private function session(string $token, User $user): array
    {
        return ['token' => $token, 'token_type' => 'Bearer', 'user' => new UserResource($user)];
    }
}
