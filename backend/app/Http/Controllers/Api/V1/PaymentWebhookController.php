<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Services\Payments\PaymentGatewayManager;
use App\Services\Payments\PaymentService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/**
 * Server-to-server notification from a payment provider. The request only tells us
 * *which* payment changed; the result is always re-fetched from the provider (PaymentService::sync).
 */
class PaymentWebhookController extends Controller
{
    public function __invoke(Request $request, string $gateway, PaymentGatewayManager $gateways, PaymentService $payments): JsonResponse
    {
        abort_unless($gateways->has($gateway), 404);

        $reference = $gateways->get($gateway)->referenceFromCallback($request);
        $payments->handleCallback($gateway, $reference);

        // Always 200 so providers don't retry forever for references that aren't ours.
        return response()->json(['received' => true]);
    }
}
