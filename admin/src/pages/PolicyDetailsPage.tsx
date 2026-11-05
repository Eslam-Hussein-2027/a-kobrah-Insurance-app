import { useQuery } from '@tanstack/react-query';
import { Link, useParams } from 'react-router';
import { CancelPolicyButton, ConfirmPaymentButton, PrintPolicyButton } from '../components/policy-actions';
import { Badge, Card, EmptyState, ErrorState, Field, Loading, PageHeader, StatusBadge, Table, Td } from '../components/ui';
import { api } from '../lib/api';
import { failureReasonLabel, formatDate, formatDateTime, formatMoney } from '../lib/format';
import type { AdminPolicy } from '../lib/types';

const FACTOR_LABELS: Record<string, string> = {
  vehicle_age: 'عمر المركبة',
  engine_cc: 'سعة المحرك',
  claims_history: 'سجل المطالبات',
};

export function PolicyDetailsPage() {
  const { id } = useParams();
  const query = useQuery({
    queryKey: ['policy', id],
    queryFn: () => api<AdminPolicy>(`/admin/policies/${id}`).then((r) => r.data),
  });

  if (query.isPending) return <Loading />;
  if (query.isError) return <ErrorState message={query.error.message} onRetry={() => query.refetch()} />;
  const p = query.data;
  const isPending = p.status.value === 'PENDING_PAYMENT';

  return (
    <>
      <PageHeader
        title={`الوثيقة ${p.policy_no}`}
        actions={
          <div className="flex flex-wrap gap-2">
            {isPending && <ConfirmPaymentButton policy={p} />}
            {p.status.value === 'ACTIVE' && <PrintPolicyButton policy={p} />}
            {isPending && <CancelPolicyButton policy={p} />}
          </div>
        }
      />

      <div className="grid gap-6 lg:grid-cols-3">
        <Card title="بيانات الوثيقة">
          <Field label="الحالة">
            <StatusBadge status={p.status} />
          </Field>
          <Field label="نوع التأمين">{p.coverage_type?.name}</Field>
          <Field label="تاريخ البداية">
            <span className="ltr">{formatDate(p.start_date)}</span>
          </Field>
          <Field label="تاريخ النهاية">
            <span className="ltr">{formatDate(p.end_date)}</span>
          </Field>
          <Field label="تاريخ الإصدار">
            <span className="ltr">{formatDateTime(p.issued_at)}</span>
          </Field>
          <Field label="القسط">
            <span className="whitespace-nowrap text-base text-navy">{formatMoney(p.premium)}</span>
          </Field>
        </Card>

        <Card title="العميل">
          {p.customer && (
            <>
              <Field label="الاسم">
                <Link to={`/customers/${p.customer.id}`} className="text-brand hover:underline">
                  {p.customer.name}
                </Link>
              </Field>
              <Field label="الهاتف">
                <span className="ltr">{p.customer.phone}</span>
              </Field>
              <Field label="الرقم الوطني">
                <span className="ltr">{p.customer.national_id ?? '—'}</span>
              </Field>
            </>
          )}
        </Card>

        <Card title="المركبة">
          {p.vehicle && (
            <>
              <Field label="رقم اللوحة">
                <span className="ltr">{p.vehicle.plate_no}</span>
              </Field>
              <Field label="رقم الهيكل">
                <span className="ltr">{p.vehicle.vin}</span>
              </Field>
              <Field label="الماركة والموديل">
                <span className="ltr">
                  {p.vehicle.make} {p.vehicle.model}
                </span>
              </Field>
              <Field label="سنة الصنع">
                <span className="ltr">{p.vehicle.year}</span>
              </Field>
              <Field label="سعة المحرك">
                <span className="ltr">{p.vehicle.engine_cc}</span> سي سي
              </Field>
            </>
          )}
        </Card>
      </div>

      <div className="mt-6 grid gap-6 lg:grid-cols-3">
        <Card title="تفاصيل التسعير عند الإصدار">
          {p.pricing_snapshot ? (
            <>
              <Field label="السعر الأساسي">
                <span className="whitespace-nowrap">{formatMoney(p.pricing_snapshot.base_price)}</span>
              </Field>
              {p.pricing_snapshot.factors.map((f) => (
                <Field key={f.type} label={`${FACTOR_LABELS[f.type] ?? f.type} (${f.input})`}>
                  <span className="ltr">× {f.multiplier}</span>
                </Field>
              ))}
              <Field label="القسط">
                <span className="whitespace-nowrap text-navy">{formatMoney(p.pricing_snapshot.premium)}</span>
              </Field>
            </>
          ) : (
            <EmptyState message="لا توجد تفاصيل" />
          )}
        </Card>

        <Card title="سجل المدفوعات" className="lg:col-span-2">
          {!p.payments?.length ? (
            <EmptyState message="لا توجد مدفوعات بعد" />
          ) : (
            <div className="-m-5">
              <Table head={['التاريخ', 'المبلغ', 'الطريقة', 'المرجع', 'الحالة', 'أكدها']}>
                {p.payments.map((pay) => (
                  <tr key={pay.id}>
                    <Td ltr>{formatDateTime(pay.paid_at ?? pay.created_at)}</Td>
                    <Td>{formatMoney(pay.amount)}</Td>
                    <Td>{pay.method.label}</Td>
                    <Td ltr>{pay.reference ?? '—'}</Td>
                    <Td>
                      <div className="flex flex-wrap items-center gap-1.5">
                        <StatusBadge status={pay.status} />
                        {pay.requires_refund && <Badge tone="bad">يحتاج استرداد</Badge>}
                        {failureReasonLabel(pay.failure_reason) && <span className="text-xs text-muted">{failureReasonLabel(pay.failure_reason)}</span>}
                      </div>
                    </Td>
                    <Td>{pay.confirmed_by ?? '—'}</Td>
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
