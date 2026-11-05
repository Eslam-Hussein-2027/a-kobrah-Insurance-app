import { useQuery } from '@tanstack/react-query';
import { Link } from 'react-router';
import { ConfirmPaymentButton } from '../components/policy-actions';
import { Card, EmptyState, ErrorState, Loading, PageHeader, Table, Td } from '../components/ui';
import { api } from '../lib/api';
import { formatDate, formatMoney, monthName } from '../lib/format';
import type { AdminPolicy, Stats } from '../lib/types';

function StatCard({ label, value, hint, tone = 'navy' }: { label: string; value: string | number; hint?: string; tone?: 'navy' | 'warn' | 'ok' | 'bad' }) {
  const colors = { navy: 'text-navy', warn: 'text-warn', ok: 'text-ok', bad: 'text-bad' };
  return (
    <div className="rounded-2xl border border-line bg-white p-5">
      <p className="text-sm text-muted">{label}</p>
      <p className={`mt-2 text-2xl font-bold whitespace-nowrap ${colors[tone]}`}>{value}</p>
      {hint && <p className="mt-1 text-xs text-muted">{hint}</p>}
    </div>
  );
}

function RevenueChart({ months }: { months: Stats['monthly'] }) {
  const max = Math.max(1, ...months.map((m) => Number(m.revenue)));
  return (
    <div className="flex items-end gap-3" role="img" aria-label="الإيرادات الشهرية">
      {months.map((m) => {
        const value = Number(m.revenue);
        return (
          <div key={m.month} className="flex flex-1 flex-col items-center gap-2">
            <span className="ltr text-xs font-bold text-navy">{value > 0 ? value.toLocaleString('en-US') : ''}</span>
            <div className="flex h-36 w-full items-end">
              <div className="w-full rounded-t-lg bg-gradient-to-t from-navy to-brand" style={{ height: `${Math.max(3, Math.round((value / max) * 144))}px` }} />
            </div>
            <span className="text-xs text-muted">{monthName(m.month)}</span>
            <span className="text-[11px] text-muted">
              <span className="ltr">{m.policies}</span> وثيقة
            </span>
          </div>
        );
      })}
    </div>
  );
}

export function OverviewPage() {
  const stats = useQuery({ queryKey: ['stats'], queryFn: () => api<Stats>('/admin/stats').then((r) => r.data) });
  const pending = useQuery({
    queryKey: ['policies', { status: 'PENDING_PAYMENT', page: 1, search: '' }],
    queryFn: () => api<AdminPolicy[]>('/admin/policies', { query: { status: 'PENDING_PAYMENT' } }),
  });

  if (stats.isPending) return <Loading />;
  if (stats.isError) return <ErrorState message={stats.error.message} onRetry={() => stats.refetch()} />;
  const s = stats.data;

  return (
    <>
      <PageHeader title="الرئيسية" subtitle="نظرة عامة على الوثائق والإيرادات" />

      <div className="grid grid-cols-2 gap-4 lg:grid-cols-4">
        <StatCard label="الوثائق السارية" value={s.policies.active} hint={`صدرت هذا الشهر: ${s.policies.issued_this_month}`} tone="ok" />
        <StatCard label="بانتظار الدفع" value={s.policies.pending_payment} tone="warn" />
        <StatCard label="إيرادات هذا الشهر" value={formatMoney(s.revenue.this_month)} />
        <StatCard label="إجمالي الإيرادات" value={formatMoney(s.revenue.total)} hint={`إلكتروني ${formatMoney(s.revenue.online)} · مكتب ${formatMoney(s.revenue.office)}`} />
        <StatCard label="العملاء" value={s.customers} />
        <StatCard label="المركبات المسجلة" value={s.vehicles} />
        <StatCard label="وثائق منتهية" value={s.policies.expired} />
        <StatCard label="مبالغ تحتاج استرداد" value={s.refunds_required} tone={s.refunds_required > 0 ? 'bad' : 'navy'} />
      </div>

      <div className="mt-6 grid gap-6 xl:grid-cols-5">
        <Card title="الإيرادات خلال آخر 6 أشهر" className="xl:col-span-2">
          <RevenueChart months={s.monthly} />
        </Card>

        <Card
          title="وثائق بانتظار الدفع"
          className="xl:col-span-3"
          actions={
            <Link to="/policies?status=PENDING_PAYMENT" className="text-sm font-bold text-brand hover:underline">
              عرض الكل
            </Link>
          }
        >
          {pending.isPending ? (
            <Loading />
          ) : pending.isError ? (
            <ErrorState message={pending.error.message} />
          ) : pending.data.data.length === 0 ? (
            <EmptyState message="لا توجد وثائق بانتظار الدفع" />
          ) : (
            <div className="-m-5">
              <Table head={['رقم الوثيقة', 'العميل', 'القسط', 'تاريخ الطلب', '']}>
                {pending.data.data.slice(0, 6).map((p) => (
                  <tr key={p.id}>
                    <Td>
                      <Link to={`/policies/${p.id}`} className="ltr font-bold text-navy hover:underline">
                        {p.policy_no}
                      </Link>
                    </Td>
                    <Td>{p.customer?.name}</Td>
                    <Td>{formatMoney(p.premium)}</Td>
                    <Td ltr>{formatDate(p.created_at)}</Td>
                    <Td className="text-end">
                      <ConfirmPaymentButton policy={p} compact />
                    </Td>
                  </tr>
                ))}
              </Table>
            </div>
          )}
        </Card>
      </div>
    </>
  );
}
