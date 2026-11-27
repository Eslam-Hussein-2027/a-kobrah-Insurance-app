<?php

namespace App\Services\Payments;

use App\Exceptions\BusinessRuleException;
use App\Models\Payment;
use Illuminate\Http\Client\ConnectionException;
use Illuminate\Http\Client\PendingRequest;
use Illuminate\Http\Client\Response;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\URL;

/**
 * DPAY (dpay.ly): Libyan wallets and bank apps behind one API.
 *
 *   open   POST {prefix}/payment/sessions/open    → session_id; the provider texts the customer a code
 *   verify POST {prefix}/payment/sessions/verify  → session_id + otp typed in our app
 *   read   GET  {prefix}/payment/sessions/{id}    → authoritative status (used after verify and on webhooks)
 *   webhook header X-Dpay-Signature = hex HMAC-SHA256(raw body, webhook secret)
 *
 * Auth: "Authorization: Bearer <token>". Sandbox: prefix /api/sandbox, code 111111 settles, 000000 declines.
 */
class DpayGateway implements OtpPaymentGateway
{
    /** Session statuses, matched case-insensitively (the provider's exact vocabulary is kept in gateway_payload). */
    private const PAID = ['paid', 'completed', 'complete', 'success', 'succeeded', 'settled', 'captured', 'approved'];

    private const FAILED = ['failed', 'declined', 'rejected', 'cancelled', 'canceled', 'expired', 'error', 'voided'];

    /** Response keys that may carry a hosted page (card methods), checked in order. */
    private const REDIRECT_KEYS = ['payment_url', 'redirect_url', 'checkout_url', 'url'];

    public function name(): string
    {
        return 'dpay';
    }

    public function payMethods(): array
    {
        return array_values((array) $this->config('pay_methods'));
    }

    public function createCheckout(Payment $payment, CheckoutInput $input): CheckoutSession
    {
        $payment->loadMissing('policy');

        $body = $this->send('post', '/payment/sessions/open', [
            'pay_method' => $input->payMethod,
            'amount' => (float) $payment->amount,
            'customer_mobile' => $input->payerPhone,
            'return_url' => URL::signedRoute('payments.result', ['payment' => $payment->id]),
            'data' => [
                'description' => 'Policy '.$payment->policy->policy_no,
                'policy_no' => $payment->policy->policy_no,
                'payment_id' => $payment->id,
            ],
        ]);

        $sessionId = $body['session_id'] ?? null;

        if (! is_scalar($sessionId) || (string) $sessionId === '') {
            Log::error('DPAY: session opened without session_id', ['payment_id' => $payment->id, 'body' => $body]);

            throw new BusinessRuleException(__('messages.payment.provider_unavailable'), 503);
        }

        $redirect = collect(self::REDIRECT_KEYS)->map(fn (string $key) => $body[$key] ?? null)->first(fn ($url) => is_string($url) && $url !== '');

        return new CheckoutSession((string) $sessionId, $redirect, requiresOtp: $redirect === null);
    }

    public function confirmOtp(Payment $payment, string $otp): GatewayResult
    {
        $response = $this->call('post', '/payment/sessions/verify', [
            'session_id' => is_numeric($payment->gateway_ref) ? (int) $payment->gateway_ref : $payment->gateway_ref,
            'otp' => $otp,
        ]);

        if ($response->serverError()) {
            throw new BusinessRuleException(__('messages.payment.provider_unavailable'), 503);
        }

        // Whatever verify answered, the session itself is the source of truth.
        $result = $this->fetchStatus($payment);

        if ($response->failed() && $result->status === GatewayResult::PENDING) {
            throw new BusinessRuleException(__('messages.payment.otp_invalid'));
        }

        return $result;
    }

    public function fetchStatus(Payment $payment): GatewayResult
    {
        try {
            $body = $this->send('get', '/payment/sessions/'.rawurlencode((string) $payment->gateway_ref));
        } catch (BusinessRuleException) {
            // Provider unreachable: keep the payment pending and ask again later (webhook / app polling).
            return GatewayResult::pending();
        }

        $session = is_array($body['session'] ?? null) ? $body['session'] : $body;
        $status = strtolower((string) ($session['status'] ?? ''));

        return match (true) {
            in_array($status, self::PAID, true) => GatewayResult::paid($this->requestedAmount($session), $session),
            in_array($status, self::FAILED, true) => GatewayResult::failed($status, $session),
            default => GatewayResult::pending($session),
        };
    }

    /**
     * The amount we asked DPAY to collect. When the customer pays DPAY's fee, the session `amount`
     * includes it (1452 + 2.9 = 1454.9) and DPAY keeps our amount in `data.original_amount`.
     *
     * @param  array<string, mixed>  $session
     */
    private function requestedAmount(array $session): string
    {
        $data = is_array($session['data'] ?? null) ? $session['data'] : [];
        $amount = $data['original_amount'] ?? $session['original_amount'] ?? $session['amount'] ?? 0;

        return number_format(is_numeric($amount) ? (float) $amount : 0.0, 2, '.', '');
    }

    /**
     * Only signed notifications are accepted; the body is then used just to find the session
     * (its status is re-read from the API, never taken from the notification).
     */
    public function referenceFromCallback(Request $request): ?string
    {
        $secret = (string) $this->config('webhook_secret');
        $signature = strtolower(trim((string) $request->header('X-Dpay-Signature')));

        if ($secret === '' || $signature === '') {
            return null;
        }

        if (! hash_equals(hash_hmac('sha256', $request->getContent(), $secret), $signature)) {
            Log::warning('DPAY: webhook with an invalid signature ignored', ['ip' => $request->ip()]);

            return null;
        }

        foreach (['session_id', 'data.session_id', 'session.id', 'id'] as $key) {
            $value = $request->input($key);

            if (is_scalar($value) && (string) $value !== '') {
                return (string) $value;
            }
        }

        return null;
    }

    // ---------------------------------------------------------------- HTTP

    /**
     * @param  array<string, mixed>  $data
     * @return array<string, mixed>
     */
    private function send(string $method, string $path, array $data = []): array
    {
        $response = $this->call($method, $path, $data);

        if ($response->failed()) {
            Log::warning('DPAY: request failed', [
                'path' => $path,
                'status' => $response->status(),
                'body' => $response->json() ?? $response->body(),
            ]);

            throw $response->clientError()
                ? new BusinessRuleException(__('messages.payment.provider_error'))
                : new BusinessRuleException(__('messages.payment.provider_unavailable'), 503);
        }

        return (array) $response->json();
    }

    /**
     * @param  array<string, mixed>  $data
     */
    private function call(string $method, string $path, array $data = []): Response
    {
        try {
            return $method === 'get'
                ? $this->client()->get($this->url($path))
                : $this->client()->post($this->url($path), $data);
        } catch (ConnectionException $exception) {
            Log::warning('DPAY: connection failed', ['path' => $path, 'error' => $exception->getMessage()]);

            throw new BusinessRuleException(__('messages.payment.provider_unavailable'), 503);
        }
    }

    private function client(): PendingRequest
    {
        $token = (string) $this->config('token');

        if ($token === '') {
            Log::error('DPAY: DPAY_API_TOKEN is not set');

            throw new BusinessRuleException(__('messages.payment.provider_unavailable'), 503);
        }

        return Http::withToken($token)
            ->acceptJson()
            ->asJson()
            ->timeout((int) $this->config('timeout_seconds'));
    }

    private function url(string $path): string
    {
        $prefix = $this->config('api_prefix') ?: ($this->config('sandbox') ? '/api/sandbox' : '/api');

        return rtrim((string) $this->config('base_url'), '/').'/'.trim((string) $prefix, '/').$path;
    }

    private function config(string $key): mixed
    {
        return config('payments.gateways.dpay.'.$key);
    }
}
