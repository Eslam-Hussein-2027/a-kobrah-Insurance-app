<?php

namespace Tests\Fakes;

use App\Services\Sms\SmsSender;

final class FakeSmsSender implements SmsSender
{
    /** @var list<array{phone: string, message: string}> */
    public array $sent = [];

    public function send(string $phone, string $message): void
    {
        $this->sent[] = ['phone' => $phone, 'message' => $message];
    }

    public function lastCodeFor(string $phone): ?string
    {
        foreach (array_reverse($this->sent) as $sms) {
            if ($sms['phone'] === $phone && preg_match('/\b(\d{6})\b/', $sms['message'], $matches)) {
                return $matches[1];
            }
        }

        return null;
    }
}
