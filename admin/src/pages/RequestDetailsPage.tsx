import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { useState } from 'react';
import { Link, useParams } from 'react-router';
import { useToast } from '../components/toast';
import { Button, Card, EmptyState, ErrorState, Field, Input, Loading, PageHeader, StatusBadge } from '../components/ui';
import type { ApiError } from '../lib/api';
import { api } from '../lib/api';
import { formatDateTime, formatMoney } from '../lib/format';
import type { InsuranceRequest, RequestStatus } from '../lib/types';

const OPEN: RequestStatus[] = ['SUBMITTED', 'IN_REVIEW', 'QUOTED'];

const ACTIONS: { value: Exclude<RequestStatus, 'SUBMITTED' | 'CANCELLED'>; label: string; hint: string }[] = [
  { value: 'IN_REVIEW', label: 'قيد المراجعة', hint: 'يرى العميل أن طلبه قيد المتابعة.' },
  { value: 'QUOTED', label: 'إرسال عرض سعر', hint: 'يظهر السعر للعميل في التطبيق.' },
  { value: 'COMPLETED', label: 'مكتمل', hint: 'صدرت الوثيقة أو انتهى الطلب.' },
  { value: 'REJECTED', label: 'رفض الطلب', hint: 'اكتب السبب ليظهر للعميل.' },
];

export function RequestDetailsPage() {
  const { id } = useParams();
  const query = useQuery({
    queryKey: ['request', id],
    queryFn: () => api<InsuranceRequest>(`/admin/requests/${id}`).then((r) => r.data),
  });

  if (query.isPending) return <Loading />;
  if (query.isError) return <ErrorState message={query.error.message} onRetry={() => query.refetch()} />;
  const r = query.data;
  const isOpen = OPEN.includes(r.status.value);

  return (
    <>
      <PageHeader title={`الطلب ${r.request_no}`} subtitle={`${r.product.label} · ${r.kind.label}`} />

      <div className="grid gap-6 lg:grid-cols-3">
        <Card title="بيانات الطلب" className="lg:col-span-2">
          <Field label="الحالة">
            <StatusBadge status={r.status} />
          </Field>
          <Field label="تاريخ الإرسال">
            <span className="ltr">{formatDateTime(r.created_at)}</span>
          </Field>
          {r.details.map((d) => (
            <Field key={d.key} label={d.label}>
              {d.value}
            </Field>
          ))}
          {r.notes && <Field label="ملاحظات العميل">{r.notes}</Field>}
        </Card>

        <div className="flex flex-col gap-6">
          <Card title="العميل">
            {r.customer && (
              <>
                <Field label="الاسم">
                  <Link to={`/customers/${r.customer.id}`} className="text-brand hover:underline">
                    {r.customer.name}
                  </Link>
                </Field>
                <Field label="الهاتف">
                  <a href={`tel:${r.customer.phone}`} className="ltr text-brand hover:underline">
                    {r.customer.phone}
                  </a>
                </Field>
              </>
            )}
          </Card>

          <Card title="المستندات المرفقة">
            {!r.documents?.length ? (
              <EmptyState message="لم يرفق العميل مستندات" />
            ) : (
              <ul className="space-y-2">
                {r.documents.map((doc) => (
                  <li key={doc.id} className="flex items-center justify-between gap-3 text-sm">
                    <span>{doc.label}</span>
                    {doc.url && (
                      <a href={doc.url} target="_blank" rel="noreferrer" className="font-bold text-brand hover:underline">
                        عرض
                      </a>
                    )}
                  </li>
                ))}
              </ul>
            )}
          </Card>
        </div>
      </div>

      <div className="mt-6 grid gap-6 lg:grid-cols-3">
        <Card title="آخر رد" className="lg:col-span-1">
          {r.replied_at ? (
            <>
              {r.quoted_amount && (
                <Field label="السعر المعروض">
                  <span className="whitespace-nowrap text-base text-navy">{formatMoney(r.quoted_amount)}</span>
                </Field>
              )}
              {r.staff_reply && <Field label="الرسالة">{r.staff_reply}</Field>}
              <Field label="التاريخ">
                <span className="ltr">{formatDateTime(r.replied_at)}</span>
              </Field>
            </>
          ) : (
            <EmptyState message="لم يتم الرد بعد" />
          )}
        </Card>

        {isOpen ? (
          <RespondForm request={r} />
        ) : (
          <Card title="الرد على الطلب" className="lg:col-span-2">
            <EmptyState message="الطلب مغلق ولا يمكن تعديله" />
          </Card>
        )}
      </div>
    </>
  );
}

function RespondForm({ request }: { request: InsuranceRequest }) {
  const toast = useToast();
  const queryClient = useQueryClient();
  const [status, setStatus] = useState<(typeof ACTIONS)[number]['value']>(request.status.value === 'SUBMITTED' ? 'IN_REVIEW' : 'QUOTED');
  const [amount, setAmount] = useState(request.quoted_amount ?? '');
  const [reply, setReply] = useState('');

  const respond = useMutation({
    mutationFn: () =>
      api<InsuranceRequest>(`/admin/requests/${request.id}/respond`, {
        method: 'POST',
        body: { status, reply: reply.trim() || null, quoted_amount: status === 'QUOTED' ? amount : null },
      }),
    onSuccess: (res) => {
      toast(res.message ?? 'تم الحفظ');
      setReply('');
      void queryClient.invalidateQueries({ queryKey: ['request', String(request.id)] });
      void queryClient.invalidateQueries({ queryKey: ['requests'] });
      void queryClient.invalidateQueries({ queryKey: ['stats'] });
    },
    onError: (e: ApiError) => toast(e.field('quoted_amount') ?? e.field('reply') ?? e.message, 'error'),
  });

  const error = respond.error as ApiError | null;

  return (
    <Card title="الرد على الطلب" className="lg:col-span-2">
      <form
        className="space-y-4"
        onSubmit={(event) => {
          event.preventDefault();
          respond.mutate();
        }}
      >
        <fieldset className="grid gap-2 sm:grid-cols-2">
          <legend className="mb-2 text-sm font-medium text-slate-700">الإجراء</legend>
          {ACTIONS.map((action) => (
            <label
              key={action.value}
              className={`flex cursor-pointer gap-3 rounded-xl border p-3 text-sm ${status === action.value ? 'border-navy bg-navy/5' : 'border-line'}`}
            >
              <input type="radio" name="status" value={action.value} checked={status === action.value} onChange={() => setStatus(action.value)} />
              <span>
                <span className="block font-bold">{action.label}</span>
                <span className="block text-xs text-muted">{action.hint}</span>
              </span>
            </label>
          ))}
        </fieldset>

        {status === 'QUOTED' && (
          <Input
            label="السعر المعروض (دينار ليبي)"
            ltr
            type="number"
            min="1"
            step="0.01"
            required
            value={amount}
            error={error?.field('quoted_amount')}
            onChange={(e) => setAmount(e.target.value)}
          />
        )}

        <label className="block">
          <span className="mb-1.5 block text-sm font-medium text-slate-700">
            رسالة للعميل {status === 'REJECTED' ? '(مطلوبة)' : '(اختيارية)'}
          </span>
          <textarea
            rows={3}
            value={reply}
            required={status === 'REJECTED'}
            onChange={(e) => setReply(e.target.value)}
            className={`w-full rounded-xl border bg-white px-3.5 py-2.5 text-sm outline-none focus:border-brand focus:ring-2 focus:ring-brand/20 ${error?.field('reply') ? 'border-bad' : 'border-line'}`}
          />
          {error?.field('reply') && <span className="mt-1 block text-xs text-bad">{error.field('reply')}</span>}
        </label>

        <Button type="submit" loading={respond.isPending}>
          حفظ الرد
        </Button>
      </form>
    </Card>
  );
}
