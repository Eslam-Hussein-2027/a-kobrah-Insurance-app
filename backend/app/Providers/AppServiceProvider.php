<?php

namespace App\Providers;

use App\Services\Sms\LogSmsSender;
use App\Services\Sms\SmsSender;
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
        $this->app->bind(SmsSender::class, fn () => match (config('insurance.sms.driver')) {
            'log' => new LogSmsSender,
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

        // OTP SMS cost money and can be abused: per phone and per IP.
        RateLimiter::for('otp', function (Request $request) {
            $phone = (string) $request->input('phone');

            return [
                Limit::perMinute(1)->by('otp:phone:min:'.$phone),
                Limit::perHour(5)->by('otp:phone:hour:'.$phone),
                Limit::perHour(20)->by('otp:ip:'.$request->ip()),
            ];
        });

        RateLimiter::for('auth', fn (Request $request) => Limit::perMinute(10)->by('auth:'.$request->ip()));

        RateLimiter::for('webhooks', fn (Request $request) => Limit::perMinute(120)->by('webhook:'.$request->ip()));

        RateLimiter::for('policy-verification', fn (Request $request) => Limit::perMinute(10)->by('verify:'.$request->ip()));
    }
}
