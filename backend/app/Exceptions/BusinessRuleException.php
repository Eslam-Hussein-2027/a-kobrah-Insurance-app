<?php

namespace App\Exceptions;

use RuntimeException;

/**
 * Thrown when a request is well-formed but violates a business rule
 * (e.g. overlapping policy, missing pricing factor). Rendered as JSON 422.
 */
class BusinessRuleException extends RuntimeException
{
    /**
     * @param  array<string, list<string>>  $errors
     */
    public function __construct(
        string $message,
        public readonly int $status = 422,
        public readonly array $errors = [],
    ) {
        parent::__construct($message);
    }
}
