<?php

namespace App\Http\Controllers\Web;

use App\Enums\PaymentStatus;
use App\Http\Controllers\Controller;
use App\Models\Payment;
use App\Services\Payments\PaymentGatewayManager;
use App\Services\Payments\PaymentService;
use App\Services\Payments\SimulatorGateway;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\URL;
use Illuminate\View\View;

/**
 * Browser pages around online payment:
 *  - the simulator's "payment page" (development/demo only)
 *  - the result page customers land on after paying (any gateway)
 * All routes are signed, so payment ids cannot be enumerated.
 */
class PaymentPageController extends Controller
{
    public function simulator(Request $request, Payment $payment, PaymentGatewayManager $gateways): View
    {
        $this->ensureSimulatorPayment($request, $payment, $gateways);

        return view('payments.simulator', [
            'payment' => $payment->load('policy'),
            'action' => URL::temporarySignedRoute(
                'payments.simulator.complete',
                now()->addMinutes((int) config('payments.checkout_ttl_minutes')),
                ['payment' => $payment->id, 'reference' => $payment->gateway_ref],
            ),
        ]);
    }

    public function completeSimulator(Request $request, Payment $payment, PaymentGatewayManager $gateways, PaymentService $payments): RedirectResponse
    {
        $this->ensureSimulatorPayment($request, $payment, $gateways);
        $request->validate(['outcome' => ['required', 'in:paid,failed']]);

        /** @var SimulatorGateway $simulator */
        $simulator = $gateways->get('simulator');
        $simulator->record($payment, $request->input('outcome') === 'paid');

        // A real provider would now call our webhook; the simulator does it inline.
        $payments->sync($payment);

        return redirect()->to(URL::temporarySignedRoute('payments.result', now()->addHour(), ['payment' => $payment->id]));
    }

    public function result(Payment $payment, PaymentService $payments): View
    {
        $payment = $payments->sync($payment)->load('policy');

        return view('payments.result', ['payment' => $payment]);
    }

    private function ensureSimulatorPayment(Request $request, Payment $payment, PaymentGatewayManager $gateways): void
    {
        abort_unless(config('payments.gateways.simulator.enabled') && $gateways->has('simulator'), 404);
        abort_unless($payment->gateway === 'simulator' && $payment->gateway_ref === $request->query('reference'), 404);
        abort_unless($payment->status === PaymentStatus::Pending, 410);
    }
}
