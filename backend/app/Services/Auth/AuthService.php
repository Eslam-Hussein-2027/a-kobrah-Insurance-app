<?php

namespace App\Services\Auth;

use App\Enums\UserDocumentType;
use App\Enums\UserRole;
use App\Models\User;
use App\Services\UserDocumentService;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Illuminate\Validation\ValidationException;

/**
 * Phone + OTP authentication.
 *
 * 1) POST /auth/otp/send      → SMS code
 * 2) POST /auth/otp/verify    → existing user: Sanctum token
 *                               new phone:     one-time registration_token (phone ownership proven)
 * 3) POST /auth/register      → registration_token + profile → Sanctum token
 */
class AuthService
{
    private const REGISTRATION_CACHE_PREFIX = 'auth:registration:';

    public function __construct(
        private readonly OtpService $otp,
        private readonly UserDocumentService $documents,
    ) {}

    /**
     * @return array{is_new_user: bool, token?: string, user?: User, registration_token?: string, expires_in?: int}
     */
    public function verifyOtp(string $phone, string $code, string $deviceName): array
    {
        if (! $this->otp->verify($phone, $code)) {
            throw ValidationException::withMessages(['code' => __('messages.otp.invalid')]);
        }

        $user = User::query()->where('phone', $phone)->first();

        if ($user !== null) {
            $this->ensureActive($user);
            $user->forceFill(['phone_verified_at' => now()])->save();

            return [
                'is_new_user' => false,
                'token' => $this->issueToken($user, $deviceName),
                'user' => $user,
            ];
        }

        $ttl = (int) config('insurance.otp.registration_token_ttl_minutes');
        $registrationToken = Str::random(64);
        Cache::put(self::REGISTRATION_CACHE_PREFIX.$registrationToken, $phone, now()->addMinutes($ttl));

        return [
            'is_new_user' => true,
            'registration_token' => $registrationToken,
            'expires_in' => $ttl * 60,
        ];
    }

    /**
     * @param  array{registration_token: string, name: string, national_id: string, device_name: string}  $data
     * @return array{token: string, user: User}
     */
    public function register(array $data, ?UploadedFile $idImage = null, ?UploadedFile $licenseImage = null): array
    {
        // One-time use: pull() removes the token even if registration fails afterwards.
        $phone = Cache::pull(self::REGISTRATION_CACHE_PREFIX.$data['registration_token']);

        if ($phone === null) {
            throw ValidationException::withMessages([
                'registration_token' => __('messages.auth.registration_token_invalid'),
            ]);
        }

        if (User::query()->where('phone', $phone)->exists()) {
            throw ValidationException::withMessages(['phone' => __('messages.auth.phone_taken')]);
        }

        $user = DB::transaction(function () use ($data, $phone) {
            $user = User::create([
                'name' => $data['name'],
                'phone' => $phone,
                'national_id' => $data['national_id'],
                'phone_verified_at' => now(),
            ]);

            return $user->assignPrimaryRole(UserRole::Customer);
        });

        if ($idImage !== null) {
            $this->documents->store($user, UserDocumentType::IdImage, $idImage);
        }

        if ($licenseImage !== null) {
            $this->documents->store($user, UserDocumentType::LicenseImage, $licenseImage);
        }

        return [
            'token' => $this->issueToken($user, $data['device_name']),
            'user' => $user->refresh(),
        ];
    }

    public function logout(User $user): void
    {
        $user->currentAccessToken()?->delete();
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
