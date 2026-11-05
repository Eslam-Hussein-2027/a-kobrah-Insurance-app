<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

/**
 * Arabic by default; English when the client sends Accept-Language: en.
 */
class SetLocale
{
    private const SUPPORTED = ['ar', 'en'];

    public function handle(Request $request, Closure $next): Response
    {
        $locale = $request->hasHeader('Accept-Language')
            ? ($request->getPreferredLanguage(self::SUPPORTED) ?? 'ar')
            : 'ar';

        app()->setLocale($locale);

        $response = $next($request);
        $response->headers->set('Content-Language', $locale);

        return $response;
    }
}
