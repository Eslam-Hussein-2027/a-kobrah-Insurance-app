<?php

namespace App\Services\Sms\Resala;

/** Result of POST /messages/send-template. Rows with invalid numbers are skipped (not sent, not charged). */
final readonly class ResalaTemplateSend
{
    /**
     * @param  list<string>  $failedNumbers
     * @param  list<string>  $invalidNumbers
     * @param  array<string, string>  $senderNames  per network: libyana, almadar, international
     */
    public function __construct(
        public bool $isProduction,
        public int $totalMessages,
        public int $succeeded,
        public int $failed,
        public float $totalCost,
        public array $failedNumbers,
        public array $invalidNumbers,
        public array $senderNames,
        public ?string $templateBody,
        public ?string $templateStatus,
    ) {}

    /**
     * @param  array<string, mixed>  $data
     */
    public static function fromArray(array $data): self
    {
        $version = is_array($data['sms_template_version'] ?? null) ? $data['sms_template_version'] : [];

        return new self(
            isProduction: (bool) ($data['is_prod'] ?? false),
            totalMessages: (int) ($data['total_messages'] ?? 0),
            succeeded: (int) ($data['succeeded'] ?? 0),
            failed: (int) ($data['failed'] ?? 0),
            totalCost: (float) ($data['total_cost'] ?? 0),
            failedNumbers: array_values(array_map('strval', (array) ($data['failed_numbers'] ?? []))),
            invalidNumbers: array_values(array_map('strval', (array) ($data['invalid_numbers'] ?? []))),
            senderNames: array_map('strval', array_filter((array) ($data['sender_names'] ?? []), 'is_scalar')),
            templateBody: isset($version['body']) ? (string) $version['body'] : null,
            templateStatus: isset($version['status']) ? (string) $version['status'] : null,
        );
    }
}
