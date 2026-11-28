<?php

namespace App\Services\Sms\Resala;

use Illuminate\Http\Client\ConnectionException;
use Illuminate\Http\Client\PendingRequest;
use Illuminate\Http\Client\Response;
use Illuminate\Support\Facades\Http;

/**
 * Resala (resala.ly) SMS API: verification codes, template messages and the sent log.
 *
 * Failed sends are never retried here: the message may already have gone out.
 * Recipients must be Libyan mobiles (091–094); they are sent in international form (218 9X XXX XXXX).
 */
class ResalaClient
{
    public function __construct(
        private readonly string $baseUrl,
        private readonly ?string $apiKey,
        /** Registered sender name (exact case). Unknown or inactive names fall back to the account default. */
        private readonly ?string $sender = null,
        /** Appended to verification texts, e.g. "رمز التحقق: 482913 - <service name>". */
        private readonly ?string $serviceName = null,
        /** Test mode: nothing is sent and nothing is charged. */
        private readonly bool $test = false,
        private readonly int $timeoutSeconds = 15,
    ) {}

    public function isTestMode(): bool
    {
        return $this->test;
    }

    /**
     * POST /pins: Resala generates a code, texts it, and returns it.
     *
     * @throws ResalaException
     */
    public function sendPin(string $phone, int $length = 6): ResalaPin
    {
        $response = $this->send('post', 'pins', [
            'service_name' => $this->serviceName,
            'len' => $length,
            'sender' => $this->sender,
            'test' => $this->test ? 1 : null,
        ], ['phone' => self::international($phone)]);

        return ResalaPin::fromArray((array) $response->json());
    }

    /**
     * POST /messages/send-template: one approved template, one row per recipient.
     * Each row is ['phone' => ..., '$1' => ..., '$2' => ..., 'scheduled_at' => optional].
     *
     * @param  list<array<string, string>>  $records
     *
     * @throws ResalaException
     */
    public function sendTemplate(string $templateId, array $records, ?string $scheduledAt = null): ResalaTemplateSend
    {
        $records = array_map(
            fn (array $row) => ['phone' => self::international((string) ($row['phone'] ?? ''))] + $row,
            $records,
        );

        $response = $this->send('post', 'messages/send-template', [
            'sms_template_id' => $templateId,
            'sender' => $this->sender,
            'scheduled_at' => $scheduledAt,
            'test' => $this->test ? 1 : null,
        ], ['records' => $records]);

        return ResalaTemplateSend::fromArray((array) $response->json());
    }

    /**
     * GET /sent-view: messages sent from the account, newest first by default.
     *
     * @throws ResalaException
     */
    public function sentMessages(int $page = 1, ?string $search = null, ?string $filters = null, ?string $sorts = null): ResalaSentPage
    {
        $response = $this->send('get', 'sent-view', [
            'page' => $page,
            'q' => $search,
            'filters' => $filters,
            'sorts' => $sorts,
        ]);

        return ResalaSentPage::fromArray((array) $response->json());
    }

    /**
     * Local 0912345678, +218 / 00218 forms → 218912345678 (the API also accepts local 09…).
     */
    public static function international(string $phone): string
    {
        $digits = preg_replace('/\D+/', '', $phone) ?? '';
        $digits = preg_replace('/^00/', '', $digits) ?? $digits;

        if (str_starts_with($digits, '218')) {
            return $digits;
        }

        return '218'.ltrim($digits, '0');
    }

    /**
     * @param  array<string, scalar|null>  $query  null values are left out
     * @param  array<string, mixed>|null  $body
     *
     * @throws ResalaException
     */
    private function send(string $method, string $path, array $query = [], ?array $body = null): Response
    {
        if (blank($this->apiKey)) {
            throw new ResalaException(ResalaErrorType::Unauthorized, 'RESALA_API_KEY is not set');
        }

        $request = $this->client()->withQueryParameters(array_filter($query, fn ($value) => $value !== null && $value !== ''));

        try {
            $response = $method === 'get' ? $request->get($path) : $request->post($path, $body ?? []);
        } catch (ConnectionException $exception) {
            throw ResalaException::connectionFailed($exception);
        }

        if ($response->failed()) {
            throw ResalaException::fromResponse($response);
        }

        return $response;
    }

    private function client(): PendingRequest
    {
        return Http::baseUrl(rtrim($this->baseUrl, '/'))
            ->withToken((string) $this->apiKey)
            ->acceptJson()
            ->asJson()
            ->timeout($this->timeoutSeconds);
    }
}
