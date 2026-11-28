<?php

namespace App\Http\Middleware;

use App\Enums\InsuranceProduct;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

/**
 * Routes of a product that is switched off in config/products.php (offered) answer 404.
 * Usage: ->middleware('offered:travel')
 */
class EnsureProductOffered
{
    public function handle(Request $request, Closure $next, string $product): Response
    {
        abort_unless(InsuranceProduct::from($product)->isOffered(), Response::HTTP_NOT_FOUND);

        return $next($request);
    }
}
