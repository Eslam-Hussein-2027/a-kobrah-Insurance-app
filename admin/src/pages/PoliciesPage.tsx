import { keepPreviousData, useQuery } from '@tanstack/react-query';
import { useEffect, useState } from 'react';
import { Link } from 'react-router';
import { Card, EmptyState, ErrorState, Input, Loading, PageHeader, Pagination, StatusBadge, Table, Td } from '../components/ui';
import { api } from '../lib/api';
import { formatDate, formatMoney } from '../lib/format';
import { useDebounced, useUrlFilters } from '../lib/hooks';
import type { AdminPolicy } from '../lib/types';

const TABS = [
  { value: '', label: 'الكل' },
  { value: 'PENDING_PAYMENT', label: 'بانتظار الدفع' },
  { value: 'ACTIVE', label: 'سارية' },
  { value: 'EXPIRED', label: 'منتهية' },
  { value: 'CANCELLED', label: 'ملغاة' },
];

export function PoliciesPage() {
  const { values, page, set } = useUrlFilters(['status', 'search'] as const);
  const [search, setSearch] = useState(values.search);
  const debounced = useDebounced(search);

  useEffect(() => {
    if (debounced !== values.search) set('search', debounced.trim());
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [debounced]);

  const query = useQuery({
    queryKey: ['policies', { status: values.status, search: values.search, page }],
    queryFn: () => api<AdminPolicy[]>('/admin/policies', { query: { status: values.status, search: values.search, page } }),
    placeholderData: keepPreviousData,
  });

  return (
    <>
      <PageHeader title="الوثائق" subtitle="جميع وثائق التأمين الصادرة وطلبات الوثائق" />

      <Card>
        <div className="-m-5">
          <div className="flex flex-wrap items-center justify-between gap-4 border-b border-line p-4">
            <div className="flex flex-wrap gap-2">
              {TABS.map((tab) => (
                <button
                  key={tab.value}
                  onClick={() => set('status', tab.value)}
                  className={`rounded-full px-4 py-1.5 text-sm font-bold ${values.status === tab.value ? 'bg-navy text-white' : 'bg-page text-slate-600 hover:bg-line'}`}
                >
                  {tab.label}
                </button>
              ))}
            </div>
            <Input
              className="w-full sm:w-80"
              placeholder="بحث برقم الوثيقة أو اللوحة أو اسم/هاتف العميل"
              value={search}
              onChange={(e) => setSearch(e.target.value)}
            />
          </div>

          {query.isPending ? (
            <Loading />
          ) : query.isError ? (
            <ErrorState message={query.error.message} onRetry={() => query.refetch()} />
          ) : query.data.data.length === 0 ? (
            <EmptyState message="لا توجد وثائق مطابقة" />
          ) : (
            <>
              <Table head={['رقم الوثيقة', 'العميل', 'الهاتف', 'رقم اللوحة', 'القسط', 'تاريخ النهاية', 'الحالة']}>
                {query.data.data.map((p) => (
                  <tr key={p.id} className="hover:bg-page/60">
                    <Td>
                      <Link to={`/policies/${p.id}`} className="ltr font-bold text-navy hover:underline">
                        {p.policy_no}
                      </Link>
                    </Td>
                    <Td>{p.customer?.name}</Td>
                    <Td ltr>{p.customer?.phone}</Td>
                    <Td ltr>{p.vehicle?.plate_no}</Td>
                    <Td>{formatMoney(p.premium)}</Td>
                    <Td ltr>{formatDate(p.end_date)}</Td>
                    <Td>
                      <StatusBadge status={p.status} />
                    </Td>
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
