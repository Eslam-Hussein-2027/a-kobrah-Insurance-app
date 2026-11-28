<?php

namespace App\Services\Sms\Resala;

/** One row of GET /sent-view. */
final readonly class ResalaSentMessage
{
    public function __construct(
        public string $id,
        /** International format, e.g. 218910001234. */
        public string $phone,
        public string $content,
        /** e.g. message, pin. */
        public string $source,
        /** e.g. delivered. */
        public string $status,
        public int $pages,
        /** production or test. */
        public string $environment,
        public ?string $createdAt,
    ) {}

    /**
     * @param  array<string, mixed>  $data
     */
    public static function fromArray(array $data): self
    {
        return new self(
            id: (string) ($data['id'] ?? ''),
            phone: ($data['code'] ?? '').($data['number'] ?? ''),
            content: (string) ($data['content'] ?? ''),
            source: (string) ($data['source'] ?? ''),
            status: (string) ($data['status'] ?? ''),
            pages: (int) ($data['pages'] ?? 1),
            environment: (string) ($data['env'] ?? ''),
            createdAt: isset($data['created_at']) ? (string) $data['created_at'] : null,
        );
    }
}
