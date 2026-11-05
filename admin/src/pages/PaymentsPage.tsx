import { keepPreviousData, useQuery } from '@tanstack/react-query';
import { Link } from 'react-router';
import { Badge, Card, EmptyState, ErrorState, Loading, PageHeader, Pagination, StatusBadge, Table, Td } from '../components/ui';
import { api } from '../lib/api';
import { failureReasonLabel, formatDateTime, formatMoney } from '../lib/format';
import { useUrlFilters } from '../lib/hooks';
import type { Payment } from '../lib/types';

const selectClass = 'rounded-xl border border-line bg-white px-3 py-2 text-sm';

export function PaymentsPage() {
  const { values, page, set } = useUrlFilters(['method', 'status', 'requires_refund'] as const);

  const query = useQuery({
    queryKey: ['payments', values, page],
    queryFn: () => api<Payment[]>('/admin/payments', { query: { ...values, page } }),
    placeholderData: keepPreviousData,
  });

  return (
    <>
      <PageHeader title="المدفوعات" subtitle="المدفوعات الإلكترونية والمدفوعات في المكتب" />

      <Card>
        <div className="-m-5">
          <div className="flex flex-wrap items-center gap-3 border-b border-line p-4">
            <select aria-label="طريقة الدفع" className={selectClass} value={values.method} onChange={(e) => set('method', e.target.value)}>
              <option value="">كل الطرق</option>
              <option value="ONLINE">دفع إلكتروني</option>
              <option value="OFFICE">الدفع في المكتب</option>
            </select>
            <select aria-label="الحالة" className={selectClass} value={values.status} onChange={(e) => set('status', e.target.value)}>
              <option value="">كل الحالات</option>
              <option value="PAID">مدفوع</option>
              <option value="PENDING">قيد الانتظار</option>
              <option value="FAILED">فشل الدفع</option>
              <option value="REFUNDED">مسترد</option>
            </select>
            <label className="flex items-center gap-2 text-sm">
              <input type="checkbox" checked={values.requires_refund === '1'} onChange={(e) => set('requires_refund', e.target.checked ? '1' : '')} />
              يحتاج استرداد فقط
            </label>
          </div>

          {query.isPending ? (
            <Loading />
          ) : query.isError ? (
            <ErrorState message={query.error.message} onRetry={() => query.refetch()} />
          ) : query.data.data.length === 0 ? (
            <EmptyState message="لا توجد مدفوعات مطابقة" />
          ) : (
            <>
              <Table head={['التاريخ', 'رقم الوثيقة', 'المبلغ', 'الطريقة', 'المرجع', 'الحالة', 'أكدها']}>
                {query.data.data.map((p) => (
                  <tr key={p.id}>
                    <Td ltr>{formatDateTime(p.paid_at ?? p.created_at)}</Td>
                    <Td>
                      {p.policy && (
                        <Link to={`/policies/${p.policy.id}`} className="ltr font-bold text-navy hover:underline">
                          {p.policy.policy_no}
                        </Link>
                      )}
                    </Td>
                    <Td>{formatMoney(p.amount)}</Td>
                    <Td>
                      {p.method.label}
                      {p.gateway && <span className="ltr ms-1 text-xs text-muted">({p.gateway})</span>}
                    </Td>
                    <Td ltr>{p.reference ?? '—'}</Td>
                    <Td>
                      <div className="flex flex-wrap items-center gap-1.5">
                        <StatusBadge status={p.status} />
                        {p.requires_refund && <Badge tone="bad">يحتاج استرداد</Badge>}
                        {failureReasonLabel(p.failure_reason) && <span className="text-xs text-muted">{failureReasonLabel(p.failure_reason)}</span>}
                      </div>
                    </Td>
                    <Td>{p.confirmed_by ?? '—'}</Td>
                  </tr>
                ))}
              </Table>
              <Pagination meta={query.data.meta?.pagination} onChange={(n) => set('page', n)} />
            </>
          )}
        </div>
      </Card>
    </>
  );
}
