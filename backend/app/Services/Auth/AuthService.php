<?php

namespace App\Services\Auth;

use App\Enums\UserRole;
use App\Models\User;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

/**
 * Customer accounts: phone number + password.
 *
 * Register  POST /auth/register         Without "code" it sends an SMS code (when phone verification is
 *                                        on) and answers 202; called again with the code it creates the
 *                                        account. With verification off the account is created directly.
 * Login     POST /auth/login
 * Forgot    POST /auth/password/forgot  → SMS code, then POST /auth/password/reset
 * Change    POST /auth/password/change  (signed in)
 *
 * Staff sign in to the dashboard with POST /auth/staff/login.
 */
class AuthService
{
    public function __construct(private readonly OtpService $otp) {}

    public function phoneVerificationRequired(): bool
    {
        return (bool) config('insurance.auth.verify_phone_on_register');
    }

    /**
     * @param  array{first_name: string, last_name: string, phone: string, address: string, password: string, device_name: string}  $data
     * @return array{verification_required: true, expires_in: int, resend_after: int}|array{verification_required: false, token: string, user: User}
     */
    public function register(array $data, ?string $code, ?string $ipAddress): array
    {
        if ($this->phoneVerificationRequired()) {
            if ($code === null) {
                $this->otp->send($data['phone'], $ipAddress);

                return [
                    'verification_required' => true,
                    'expires_in' => $this->otp->ttlMinutes() * 60,
                    'resend_after' => $this->otp->resendAfterSeconds(),
                ];
            }

            $this->verifyCode($data['phone'], $code);
        }

        $user = DB::transaction(fn () => User::create([
            'name' => trim($data['first_name']).' '.trim($data['last_name']),
            'phone' => $data['phone'],
            'address' => $data['address'],
            'password' => $data['password'],
            'phone_verified_at' => $this->phoneVerificationRequired() ? now() : null,
        ])->assignPrimaryRole(UserRole::Customer));

        return [
            'verification_required' => false,
            'token' => $this->issueToken($user, $data['device_name']),
            'user' => $user->refresh(),
        ];
    }

    /**
     * Customers only; staff use the dashboard login. The same message for a wrong phone or password.
     *
     * @return array{token: string, user: User}
     */
    public function login(string $phone, string $password, string $deviceName): array
    {
        $user = User::query()->where('phone', $phone)->where('role', UserRole::Customer)->first();

        if (! $this->passwordMatches($user, $password)) {
            throw ValidationException::withMessages(['phone' => __('messages.auth.invalid_credentials')]);
        }

        $this->ensureActive($user);

        return ['token' => $this->issueToken($user, $deviceName), 'user' => $user];
    }

    /**
     * Sends a code only to a registered, active customer; the answer is the same either way,
     * so the endpoint does not reveal which numbers have an account.
     */
    public function sendPasswordResetCode(string $phone, ?string $ipAddress): void
    {
        $exists = User::query()
            ->where('phone', $phone)
            ->where('role', UserRole::Customer)
            ->where('is_active', true)
            ->exists();

        if ($exists) {
            $this->otp->send($phone, $ipAddress);
        }
    }

    /**
     * New password after proving the phone with an SMS code. Other devices are signed out.
     *
     * @return array{token: string, user: User}
     */
    public function resetPassword(string $phone, string $code, string $password, string $deviceName): array
    {
        $user = User::query()->where('phone', $phone)->where('role', UserRole::Customer)->first();

        // Unknown numbers get the same "wrong code" answer as a wrong code.
        if ($user === null) {
            throw ValidationException::withMessages(['code' => __('messages.otp.invalid')]);
        }

        $this->verifyCode($phone, $code);
        $this->ensureActive($user);

        $user->forceFill(['password' => $password, 'phone_verified_at' => now()])->save();
        $user->tokens()->delete();

        return ['token' => $this->issueToken($user, $deviceName), 'user' => $user];
    }

    /** Keeps the current session and signs out the other devices. */
    public function changePassword(User $user, string $currentPassword, string $newPassword): void
    {
        if (! $this->passwordMatches($user, $currentPassword)) {
            throw ValidationException::withMessages(['current_password' => __('messages.auth.current_password_wrong')]);
        }

        $user->forceFill(['password' => $newPassword])->save();

        $current = $user->currentAccessToken();
        $user->tokens()->when($current !== null, fn ($query) => $query->whereKeyNot($current->getKey()))->delete();
    }

    /**
     * Dashboard login for staff (admin, surveyor, workshop) with phone + password.
     *
     * @return array{token: string, user: User}
     */
    public function staffLogin(string $phone, string $password, string $deviceName): array
    {
        $user = User::query()->where('phone', $phone)->where('role', '!=', UserRole::Customer)->first();

        if (! $this->passwordMatches($user, $password)) {
            throw ValidationException::withMessages(['phone' => __('messages.auth.invalid_credentials')]);
        }

        $this->ensureActive($user);

        return ['token' => $this->issueToken($user, $deviceName), 'user' => $user];
    }

    public function logout(User $user): void
    {
        $user->currentAccessToken()?->delete();
    }

    /** @phpstan-assert-if-true User $user */
    private function passwordMatches(?User $user, string $password): bool
    {
        return $user !== null
            && $user->getAuthPassword() !== null
            && Hash::check($password, $user->getAuthPassword());
    }

    private function verifyCode(string $phone, string $code): void
    {
        if (! $this->otp->verify($phone, $code)) {
            throw ValidationException::withMessages(['code' => __('messages.otp.invalid')]);
        }
    }

    private function issueToken(User $user, string $deviceName): string
    {
        return $user->createToken($deviceName)->plainTextToken;
    }

    private function ensureActive(User $user): void
    {
        if (! $user->is_active) {
            throw ValidationException::withMessages(['phone' => __('messages.auth.account_disabled')]);
        }
    }
}
