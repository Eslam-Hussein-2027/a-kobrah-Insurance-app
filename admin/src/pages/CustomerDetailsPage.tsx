import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { useState } from 'react';
import { Link, useParams } from 'react-router';
import { useToast } from '../components/toast';
import { Badge, Button, Card, EmptyState, ErrorState, Field, Loading, PageHeader, StatusBadge, Table, Td } from '../components/ui';
import type { ApiError } from '../lib/api';
import { api } from '../lib/api';
import { formatDate, formatMoney } from '../lib/format';
import type { Customer } from '../lib/types';

export function CustomerDetailsPage() {
  const { id } = useParams();
  const toast = useToast();
  const queryClient = useQueryClient();

  const query = useQuery({
    queryKey: ['customer', id],
    queryFn: () => api<Customer>(`/admin/customers/${id}`).then((r) => r.data),
  });

  const toggle = useMutation({
    mutationFn: (isActive: boolean) => api<Customer>(`/admin/customers/${id}`, { method: 'PATCH', body: { is_active: isActive } }),
    onSuccess: (res) => {
      toast(res.message ?? 'تم الحفظ');
      void queryClient.invalidateQueries({ queryKey: ['customer', id] });
      void queryClient.invalidateQueries({ queryKey: ['customers'] });
    },
    onError: (e: ApiError) => toast(e.message, 'error'),
  });

  if (query.isPending) return <Loading />;
  if (query.isError) return <ErrorState message={query.error.message} onRetry={() => query.refetch()} />;
  const c = query.data;

  return (
    <>
      <PageHeader
        title={c.name}
        subtitle="بيانات العميل ومركباته ووثائقه"
        actions={
          c.is_active ? (
            <Button variant="danger" loading={toggle.isPending} onClick={() => toggle.mutate(false)}>
              إيقاف الحساب
            </Button>
          ) : (
            <Button loading={toggle.isPending} onClick={() => toggle.mutate(true)}>
              تفعيل الحساب
            </Button>
          )
        }
      />

      <div className="grid gap-6 lg:grid-cols-3">
        <Card title="البيانات الشخصية">
          <Field label="الهاتف">
            <span className="ltr">{c.phone}</span>
          </Field>
          <Field label="الرقم الوطني">
            <span className="ltr">{c.national_id ?? '—'}</span>
          </Field>
          <Field label="الحساب">{c.is_active ? <Badge tone="ok">نشط</Badge> : <Badge tone="bad">موقوف</Badge>}</Field>
          <Field label="تاريخ التسجيل">
            <span className="ltr">{formatDate(c.created_at)}</span>
          </Field>
        </Card>

        <Card title="المستندات" className="lg:col-span-2">
          <div className="grid gap-4 sm:grid-cols-2">
            {Object.entries(c.documents).map(([key, doc]) => (
              <div key={key} className="rounded-xl border border-line p-3">
                <p className="mb-2 text-sm font-bold">{doc.label}</p>
                {doc.uploaded && doc.url ? (
                  <DocumentImage url={doc.url} label={doc.label} />
                ) : (
                  <div className="flex h-40 items-center justify-center rounded-lg bg-page text-sm text-muted">لم يتم الرفع</div>
                )}
              </div>
            ))}
          </div>
        </Card>
      </div>

      <div className="mt-6 grid gap-6 lg:grid-cols-2">
        <Card title="المركبات">
          {!c.vehicles?.length ? (
            <EmptyState message="لا توجد مركبات" />
          ) : (
            <div className="-m-5">
              <Table head={['رقم اللوحة', 'الماركة والموديل', 'سنة الصنع', 'المحرك']}>
                {c.vehicles.map((v) => (
                  <tr key={v.id}>
                    <Td ltr>{v.plate_no}</Td>
                    <Td ltr>
                      {v.make} {v.model}
                    </Td>
                    <Td ltr>{v.year}</Td>
                    <Td ltr>{v.engine_cc}</Td>
                  </tr>
                ))}
              </Table>
            </div>
          )}
        </Card>

        <Card title="الوثائق">
          {!c.policies?.length ? (
            <EmptyState message="لا توجد وثائق" />
          ) : (
            <div className="-m-5">
              <Table head={['رقم الوثيقة', 'اللوحة', 'القسط', 'الحالة']}>
                {c.policies.map((p) => (
                  <tr key={p.id}>
                    <Td>
                      <Link to={`/policies/${p.id}`} className="ltr font-bold text-navy hover:underline">
                        {p.policy_no}
                      </Link>
                    </Td>
                    <Td ltr>{p.vehicle?.plate_no}</Td>
                    <Td>{formatMoney(p.premium)}</Td>
                    <Td>
                      <StatusBadge status={p.status} />
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

/** Signed, short-lived image URL from the API; shows a clear message if the file can't be displayed. */
function DocumentImage({ url, label }: { url: string; label: string }) {
  const [failed, setFailed] = useState(false);
  if (failed) {
    return <div className="flex h-40 items-center justify-center rounded-lg bg-page text-sm text-muted">تعذّر عرض الصورة</div>;
  }
  return (
    <a href={url} target="_blank" rel="noreferrer">
      <img src={url} alt={label} onError={() => setFailed(true)} className="h-40 w-full rounded-lg bg-page object-contain" />
    </a>
  );
}
