<?php

namespace App\Services\Sms\Resala;

use Illuminate\Http\Client\Response;
use RuntimeException;
use Throwable;

class ResalaException extends RuntimeException
{
    /**
     * @param  array<string, list<string>>  $errors  per-field messages (InputValidation)
     */
    public function __construct(
        public readonly ResalaErrorType $type,
        string $message,
        public readonly ?int $status = null,
        public readonly array $errors = [],
        ?Throwable $previous = null,
    ) {
        parent::__construct($message, $status ?? 0, $previous);
    }

    public static function fromResponse(Response $response): self
    {
        $body = $response->json();
        $body = is_array($body) ? $body : [];

        return new self(
            ResalaErrorType::tryFrom((string) ($body['type'] ?? '')) ?? ResalaErrorType::Unknown,
            (string) ($body['message'] ?? 'Resala request failed'),
            $response->status(),
            self::fieldErrors($body['errors'] ?? []),
        );
    }

    public static function connectionFailed(Throwable $previous): self
    {
        return new self(ResalaErrorType::ConnectionFailed, $previous->getMessage(), previous: $previous);
    }

    /**
     * @return array<string, list<string>>
     */
    private static function fieldErrors(mixed $errors): array
    {
        if (! is_array($errors)) {
            return [];
        }

        return collect($errors)
            ->map(fn ($messages) => array_values(array_map('strval', (array) $messages)))
            ->all();
    }
}
