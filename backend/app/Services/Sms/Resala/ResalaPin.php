<?php

namespace App\Services\Sms\Resala;

/** A verification code Resala generated and texted (POST /pins). */
final readonly class ResalaPin
{
    public function __construct(
        public string $id,
        public string $pin,
        /** International format, e.g. 218910001234. */
        public string $phone,
        public string $content,
        /** The sender name actually used on the recipient's network. */
        public ?string $senderName,
    ) {}

    /**
     * @param  array<string, mixed>  $data
     */
    public static function fromArray(array $data): self
    {
        return new self(
            id: (string) ($data['id'] ?? ''),
            pin: (string) ($data['pin'] ?? ''),
            phone: ($data['code'] ?? '').($data['number'] ?? ''),
            content: (string) ($data['content'] ?? ''),
            senderName: isset($data['sender_name']) ? (string) $data['sender_name'] : null,
        );
    }
}
