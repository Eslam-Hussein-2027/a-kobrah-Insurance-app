<?php

namespace App\Providers;

use App\Services\Auth\Otp\OtpSender;
use App\Services\Auth\Otp\ResalaOtpSender;
use App\Services\Auth\Otp\TextMessageOtpSender;
use App\Services\Sms\LogSmsSender;
use App\Services\Sms\Resala\ResalaClient;
use App\Services\Sms\SmsSender;
use App\Support\PhoneNumber;
use Carbon\CarbonImmutable;
use Illuminate\Cache\RateLimiting\Limit;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Date;
use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Support\ServiceProvider;
use InvalidArgumentException;

class AppServiceProvider extends ServiceProvider
{
    public function register(): void
    {
        // Plain texts are only logged for now (Resala sends free text through approved templates).
        $this->app->bind(SmsSender::class, LogSmsSender::class);

        $this->app->bind(ResalaClient::class, fn () => new ResalaClient(
            baseUrl: (string) config('insurance.sms.resala.base_url'),
            apiKey: config('insurance.sms.resala.api_key'),
            sender: config('insurance.sms.resala.sender') ?: null,
            serviceName: config('insurance.sms.resala.service_name') ?: null,
            test: (bool) config('insurance.sms.resala.test'),
            timeoutSeconds: (int) config('insurance.sms.resala.timeout_seconds'),
        ));

        // Sign-up and password-reset codes.
        $this->app->bind(OtpSender::class, fn ($app) => match (config('insurance.sms.driver')) {
            'log' => new TextMessageOtpSender($app->make(SmsSender::class)),
            'resala' => new ResalaOtpSender($app->make(ResalaClient::class)),
            default => throw new InvalidArgumentException('Unsupported SMS driver: '.config('insurance.sms.driver')),
        });
    }

    public function boot(): void
    {
        Date::use(CarbonImmutable::class);

        // Fail loudly in development on N+1 queries and silently-dropped attributes.
        Model::shouldBeStrict(! $this->app->isProduction());

        $this->configureRateLimiting();
    }

    private function configureRateLimiting(): void
    {
        RateLimiter::for('api', fn (Request $request) => Limit::perMinute(60)->by($request->user()?->id ?: $request->ip()));

        RateLimiter::for('auth', fn (Request $request) => Limit::perMinute(10)->by('auth:'.$request->ip()));

        // Password guessing: per phone and per IP. (SMS codes are limited inside OtpService.)
        RateLimiter::for('login', fn (Request $request) => [
            Limit::perMinute(5)->by('login:phone:'.PhoneNumber::normalize((string) $request->input('phone'))),
            Limit::perMinute(20)->by('login:ip:'.$request->ip()),
        ]);

        RateLimiter::for('webhooks', fn (Request $request) => Limit::perMinute(120)->by('webhook:'.$request->ip()));

        RateLimiter::for('qr-verification', fn (Request $request) => Limit::perMinute(60)->by('qr:'.$request->ip()));

        // Payment codes: a few tries per payment, so a code can't be guessed.
        RateLimiter::for('payment-otp', fn (Request $request) => Limit::perMinute(5)->by('payment-otp:'.$request->user()?->id.':'.$request->route('payment')));

        RateLimiter::for('policy-verification', fn (Request $request) => Limit::perMinute(10)->by('verify:'.$request->ip()));
    }
}
