<?php

namespace App\Services\Admin;

use App\Enums\PaymentStatus;
use App\Enums\PolicyStatus;
use App\Enums\UserRole;
use App\Models\Payment;
use App\Models\Policy;
use App\Models\User;
use App\Models\Vehicle;
use Carbon\CarbonImmutable;

/**
 * Numbers for the admin dashboard home page. Aggregations are done in PHP over small
 * per-month windows so the same code runs on MySQL and SQLite.
 */
class DashboardStatsService
{
    private const MONTHS = 6;

    /**
     * @return array<string, mixed>
     */
    public function summary(): array
    {
        $monthStart = CarbonImmutable::now()->startOfMonth();
        $paid = Payment::query()->where('status', PaymentStatus::Paid);

        $policyCounts = Policy::query()
            ->selectRaw('status, COUNT(*) as total')
            ->groupBy('status')
            ->pluck('total', 'status');

        return [
            'policies' => [
                'active' => (int) ($policyCounts[PolicyStatus::Active->value] ?? 0),
                'pending_payment' => (int) ($policyCounts[PolicyStatus::PendingPayment->value] ?? 0),
                'expired' => (int) ($policyCounts[PolicyStatus::Expired->value] ?? 0),
                'cancelled' => (int) ($policyCounts[PolicyStatus::Cancelled->value] ?? 0),
                'issued_this_month' => Policy::query()->where('issued_at', '>=', $monthStart)->count(),
            ],
            'revenue' => [
                'currency' => config('insurance.currency'),
                'total' => $this->money((clone $paid)->sum('amount')),
                'this_month' => $this->money((clone $paid)->where('paid_at', '>=', $monthStart)->sum('amount')),
                'online' => $this->money((clone $paid)->where('method', 'ONLINE')->sum('amount')),
                'office' => $this->money((clone $paid)->where('method', 'OFFICE')->sum('amount')),
            ],
            'customers' => User::query()->where('role', UserRole::Customer)->count(),
            'vehicles' => Vehicle::query()->count(),
            'refunds_required' => Payment::query()->where('requires_refund', true)->where('status', '!=', PaymentStatus::Refunded)->count(),
            'monthly' => $this->monthly(),
        ];
    }

    /**
     * @return list<array{month: string, policies: int, revenue: string}>
     */
    private function monthly(): array
    {
        $from = CarbonImmutable::now()->startOfMonth()->subMonths(self::MONTHS - 1);

        $issued = Policy::query()->where('issued_at', '>=', $from)->pluck('issued_at')
            ->countBy(fn ($date) => CarbonImmutable::parse($date)->format('Y-m'));

        $revenue = Payment::query()->where('status', PaymentStatus::Paid)->where('paid_at', '>=', $from)->get(['amount', 'paid_at'])
            ->groupBy(fn (Payment $p) => $p->paid_at->format('Y-m'))
            ->map(fn ($group) => $group->sum(fn (Payment $p) => (float) $p->amount));

        $months = [];
        for ($i = 0; $i < self::MONTHS; $i++) {
            $key = $from->addMonths($i)->format('Y-m');
            $months[] = [
                'month' => $key,
                'policies' => (int) ($issued[$key] ?? 0),
                'revenue' => $this->money($revenue[$key] ?? 0),
            ];
        }

        return $months;
    }

    private function money(float|int|string|null $value): string
    {
        return number_format((float) $value, 2, '.', '');
    }
}
