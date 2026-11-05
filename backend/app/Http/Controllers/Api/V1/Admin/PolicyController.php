<?php

namespace App\Http\Controllers\Api\V1\Admin;

use App\Enums\PolicyStatus;
use App\Exceptions\BusinessRuleException;
use App\Http\Controllers\Controller;
use App\Http\Resources\Admin\AdminPolicyResource;
use App\Http\Responses\ApiResponse;
use App\Models\Policy;
use App\Services\Policy\PolicyPdfService;
use App\Services\Policy\PolicyService;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;
use Symfony\Component\HttpFoundation\StreamedResponse;

class PolicyController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $request->validate([
            'status' => ['nullable', Rule::enum(PolicyStatus::class)],
            'search' => ['nullable', 'string', 'max:50'],
        ]);

        $policies = Policy::query()
            ->with(['vehicle.user', 'coverageType'])
            ->when($request->filled('status'), fn (Builder $q) => $q->where('status', $request->input('status')))
            ->when($request->filled('search'), fn (Builder $q) => $this->search($q, (string) $request->input('search')))
            ->latest('id')
            ->paginate(20);

        return ApiResponse::paginated($policies, AdminPolicyResource::class);
    }

    public function show(Policy $policy): JsonResponse
    {
        $policy->load(['vehicle.user', 'coverageType', 'payments.confirmedBy']);

        return ApiResponse::success(new AdminPolicyResource($policy));
    }

    public function cancel(Policy $policy, PolicyService $policies): JsonResponse
    {
        $policies->cancelPending($policy);

        return ApiResponse::success(
            new AdminPolicyResource($policy->load(['vehicle.user', 'coverageType', 'payments.confirmedBy'])),
            __('messages.policy.cancelled'),
        );
    }

    /** Printing at the office (e.g. after an office payment). */
    public function pdf(Policy $policy, PolicyPdfService $pdf): StreamedResponse
    {
        if (! $policy->isActive()) {
            throw new BusinessRuleException(__('messages.policy.not_active'), 403);
        }

        return $pdf->disk()->download($pdf->ensure($policy), $policy->policy_no.'.pdf', [
            'Content-Type' => 'application/pdf',
            'Cache-Control' => 'private, no-store',
        ]);
    }

    private function search(Builder $query, string $term): void
    {
        $like = '%'.addcslashes(trim($term), '%_\\').'%';

        $query->where(fn (Builder $q) => $q
            ->where('policy_no', 'like', $like)
            ->orWhereHas('vehicle', fn (Builder $v) => $v
                ->where('plate_no', 'like', $like)
                ->orWhereHas('user', fn (Builder $u) => $u
                    ->where('name', 'like', $like)
                    ->orWhere('phone', 'like', $like)
                    ->orWhere('national_id', 'like', $like))));
    }
}
