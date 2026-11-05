<?php

namespace App\Exceptions;

use App\Http\Responses\ApiResponse;
use Illuminate\Auth\Access\AuthorizationException;
use Illuminate\Auth\AuthenticationException;
use Illuminate\Database\Eloquent\ModelNotFoundException;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Routing\Exceptions\InvalidSignatureException;
use Illuminate\Validation\ValidationException;
use Symfony\Component\HttpKernel\Exception\HttpExceptionInterface;
use Throwable;

/**
 * Converts any exception thrown under /api/* into the standard JSON envelope with localized messages.
 *
 * Note: Laravel's handler runs prepareException() first, so AuthorizationException arrives as
 * AccessDeniedHttpException and ModelNotFoundException as NotFoundHttpException (originals kept as previous).
 */
final class ApiExceptionRenderer
{
    public static function render(Throwable $e, Request $request): ?JsonResponse
    {
        if (! $request->is('api/*')) {
            return null;
        }

        return match (true) {
            $e instanceof ValidationException => ApiResponse::error(
                __('messages.errors.validation'),
                $e->status,
                $e->errors(),
            ),

            $e instanceof BusinessRuleException => ApiResponse::error($e->getMessage(), $e->status, $e->errors),

            $e instanceof AuthenticationException => ApiResponse::error(__('messages.errors.unauthenticated'), 401),

            $e instanceof InvalidSignatureException => ApiResponse::error(__('messages.errors.invalid_signature'), 403),

            $e instanceof HttpExceptionInterface => self::renderHttpException($e),

            default => self::renderServerError($e),
        };
    }

    private static function renderHttpException(HttpExceptionInterface&Throwable $e): JsonResponse
    {
        $status = $e->getStatusCode();
        $previous = $e->getPrevious();

        $message = match (true) {
            $status === 403 && $previous instanceof AuthorizationException && self::hasCustomMessage($previous) => $previous->getMessage(),
            $status === 403 => __('messages.errors.forbidden'),
            $status === 404 && $previous instanceof ModelNotFoundException => __('messages.errors.model_not_found'),
            $status === 404 => __('messages.errors.route_not_found'),
            $status === 405 => __('messages.errors.method_not_allowed'),
            $status === 429 => __('messages.errors.too_many_requests'),
            default => $e->getMessage() !== '' ? $e->getMessage() : __('messages.errors.server_error'),
        };

        return ApiResponse::error($message, $status, headers: $e->getHeaders());
    }

    private static function renderServerError(Throwable $e): JsonResponse
    {
        $errors = config('app.debug')
            ? ['exception' => [$e::class.': '.$e->getMessage()]]
            : [];

        return ApiResponse::error(__('messages.errors.server_error'), 500, $errors);
    }

    private static function hasCustomMessage(AuthorizationException $e): bool
    {
        return $e->getMessage() !== '' && $e->getMessage() !== 'This action is unauthorized.';
    }
}
