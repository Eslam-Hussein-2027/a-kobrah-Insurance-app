<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use App\Models\Policy;
use App\Services\Policy\PolicyVerificationService;
use App\Support\Digits;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Support\Facades\Validator;

/**
 * Public web page for police, government bodies and companies — no app or account needed.
 *  - /verify                         form (policy number + plate number)
 *  - /verify/{policy_no}/{token}     opened by scanning the QR code printed on the policy
 */
class PublicVerificationController extends Controller
{
    public function __construct(private readonly PolicyVerificationService $verifier) {}

    public function form(Request $request): Response
    {
        if (! $request->filled('policy_no') && ! $request->filled('plate_no')) {
            return response()->view('verify.form');
        }

        $input = [
            'policy_no' => strtoupper((string) Digits::toWestern((string) $request->query('policy_no'))),
            'plate_no' => (string) Digits::toWestern((string) $request->query('plate_no')),
        ];

        $validator = Validator::make($input, [
            'policy_no' => ['required', 'regex:'.config('insurance.validation.policy_no_regex')],
            'plate_no' => ['required', 'string', 'max:20'],
        ]);

        if ($validator->fails()) {
            return response()->view('verify.form', ['formErrors' => $validator->errors(), 'input' => $input], 422);
        }

        $policy = $this->verifier->findByPlate($input['policy_no'], $input['plate_no']);

        return $this->result($policy, detailed: false);
    }

    public function qr(string $policyNo, string $token): Response
    {
        return $this->result($this->verifier->findByToken($policyNo, $token), detailed: true);
    }

    private function result(?Policy $policy, bool $detailed): Response
    {
        if ($policy === null) {
            return response()->view('verify.result', ['policy' => null, 'detailed' => $detailed], 404);
        }

        return response()->view('verify.result', [
            'policy' => $policy,
            'status' => $this->verifier->publicStatus($policy),
            'detailed' => $detailed,
        ])->header('Cache-Control', 'no-store');
    }
}
