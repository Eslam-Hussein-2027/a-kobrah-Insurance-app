<?php

namespace App\Jobs;

use App\Models\Policy;
use App\Services\Policy\PolicyPdfService;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Queue\Queueable;

class GeneratePolicyPdf implements ShouldQueue
{
    use Queueable;

    public int $tries = 3;

    /** @var list<int> */
    public array $backoff = [10, 60];

    public function __construct(public readonly int $policyId) {}

    public function handle(PolicyPdfService $pdf): void
    {
        $policy = Policy::query()->find($this->policyId);

        if ($policy === null || ! $policy->isActive()) {
            return;
        }

        // ensure(): a download may already have generated it synchronously before the worker ran.
        $pdf->ensure($policy);
    }
}
