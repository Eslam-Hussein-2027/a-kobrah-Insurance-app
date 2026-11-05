<?php

namespace App\Http\Responses;

use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * Single JSON envelope for every API response.
 *
 * Success: { "success": true,  "message": "...", "data": {...}, "meta": {...}? }
 * Error:   { "success": false, "message": "...", "errors": {...}? }
 */
final class ApiResponse
{
    /** Arabic text stays human-readable (and ~3x smaller) instead of \uXXXX escapes. */
    private const JSON_OPTIONS = JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES;

    /**
     * @param  array<string, mixed>  $meta
     */
    public static function success(
        mixed $data = null,
        ?string $message = null,
        int $status = 200,
        array $meta = [],
    ): JsonResponse {
        $payload = [
            'success' => true,
            'message' => $message,
            'data' => $data instanceof JsonResource ? $data->resolve(request()) : $data,
        ];

        if ($meta !== []) {
            $payload['meta'] = $meta;
        }

        return response()->json($payload, $status, [], self::JSON_OPTIONS);
    }

    public static function created(mixed $data = null, ?string $message = null): JsonResponse
    {
        return self::success($data, $message, 201);
    }

    /**
     * @param  class-string<JsonResource>  $resource
     */
    public static function paginated(LengthAwarePaginator $paginator, string $resource, ?string $message = null): JsonResponse
    {
        return self::success(
            $resource::collection($paginator->getCollection()),
            $message,
            meta: [
                'pagination' => [
                    'current_page' => $paginator->currentPage(),
                    'per_page' => $paginator->perPage(),
                    'total' => $paginator->total(),
                    'last_page' => $paginator->lastPage(),
                ],
            ],
        );
    }

    /**
     * @param  array<string, mixed>  $errors
     * @param  array<string, string>  $headers
     */
    public static function error(string $message, int $status, array $errors = [], array $headers = []): JsonResponse
    {
        $payload = ['success' => false, 'message' => $message];

        if ($errors !== []) {
            $payload['errors'] = $errors;
        }

        return response()->json($payload, $status, $headers, self::JSON_OPTIONS);
    }
}
