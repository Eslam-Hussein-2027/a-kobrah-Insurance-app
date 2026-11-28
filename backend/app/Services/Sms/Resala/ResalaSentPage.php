<?php

namespace App\Services\Sms\Resala;

/** A page of GET /sent-view. */
final readonly class ResalaSentPage
{
    /**
     * @param  list<ResalaSentMessage>  $messages
     */
    public function __construct(
        public array $messages,
        public int $total,
        public int $perPage,
        public int $currentPage,
        public int $lastPage,
    ) {}

    /**
     * @param  array<string, mixed>  $data
     */
    public static function fromArray(array $data): self
    {
        $meta = is_array($data['meta'] ?? null) ? $data['meta'] : [];

        return new self(
            messages: array_values(array_map(
                fn (array $row) => ResalaSentMessage::fromArray($row),
                array_filter((array) ($data['data'] ?? []), 'is_array'),
            )),
            total: (int) ($meta['total'] ?? 0),
            perPage: (int) ($meta['per_page'] ?? 0),
            currentPage: (int) ($meta['current_page'] ?? 1),
            lastPage: (int) ($meta['last_page'] ?? 1),
        );
    }
}
