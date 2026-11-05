<?php

namespace App\Http\Controllers\Api\V1\Admin;

use App\Enums\PaymentMethod;
use App\Enums\PaymentStatus;
use App\Http\Controllers\Controller;
use App\Http\Resources\PaymentResource;
use App\Http\Responses\ApiResponse;
use App\Models\Payment;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class PaymentController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $request->validate([
            'status' => ['nullable', Rule::enum(PaymentStatus::class)],
            'method' => ['nullable', Rule::enum(PaymentMethod::class)],
            'requires_refund' => ['nullable', 'boolean'],
        ]);

        $payments = Payment::query()
            ->with(['policy.vehicle', 'policy.coverageType', 'confirmedBy'])
            ->when($request->filled('status'), fn (Builder $q) => $q->where('status', $request->input('status')))
            ->when($request->filled('method'), fn (Builder $q) => $q->where('method', $request->input('method')))
            ->when($request->boolean('requires_refund'), fn (Builder $q) => $q->where('requires_refund', true))
            ->latest('id')
            ->paginate(20);

        return ApiResponse::paginated($payments, PaymentResource::class);
    }
}
