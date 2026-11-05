<?php

namespace App\Services\Policy;

use App\Models\Policy;
use Illuminate\Contracts\Filesystem\Filesystem;
use Illuminate\Support\Facades\Storage;
use Mccarlosen\LaravelMpdf\Facades\LaravelMpdf;

/**
 * Renders the printable A4 policy document (Arabic, RTL, black & white) with mPDF
 * and stores it on a private disk.
 */
class PolicyPdfService
{
    public function render(Policy $policy): string
    {
        $policy->loadMissing(['vehicle.user', 'coverageType']);

        $pdf = LaravelMpdf::loadView('pdf.policy', [
            'policy' => $policy,
            'vehicle' => $policy->vehicle,
            'customer' => $policy->vehicle->user,
            'coverage' => $policy->coverageType,
            'company' => config('insurance.company'),
            'currency_label' => config('insurance.currency_label'),
            'logo' => $this->existingPath(config('insurance.company.logo_path')),
            'stamp' => $this->existingPath(config('insurance.company.stamp_path')),
        ], [], [
            'title' => $policy->policy_no,
            'subject' => __('pdf.title'),
        ]);

        return $pdf->output();
    }

    /**
     * Generate (or regenerate) the PDF and persist its path on the policy.
     */
    public function generate(Policy $policy): string
    {
        $path = sprintf(
            '%s/%s/%s.pdf',
            config('insurance.policy.pdf_directory'),
            $policy->issued_at?->format('Y') ?? now()->format('Y'),
            $policy->policy_no,
        );

        $this->disk()->put($path, $this->render($policy));
        $policy->forceFill(['pdf_path' => $path])->saveQuietly();

        return $path;
    }

    /**
     * Return the stored PDF path, generating it synchronously if the queued job hasn't run yet.
     */
    public function ensure(Policy $policy): string
    {
        if ($policy->pdf_path !== null && $this->disk()->exists($policy->pdf_path)) {
            return $policy->pdf_path;
        }

        return $this->generate($policy);
    }

    public function disk(): Filesystem
    {
        return Storage::disk((string) config('insurance.policy.pdf_disk'));
    }

    private function existingPath(?string $path): ?string
    {
        return $path !== null && is_file($path) ? $path : null;
    }
}
