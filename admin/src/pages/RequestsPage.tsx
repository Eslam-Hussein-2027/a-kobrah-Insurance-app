import { keepPreviousData, useQuery } from '@tanstack/react-query';
import { useEffect, useState } from 'react';
import { Link } from 'react-router';
import { Card, EmptyState, ErrorState, Input, Loading, PageHeader, Pagination, StatusBadge, Table, Td } from '../components/ui';
import { api } from '../lib/api';
import { formatDateTime } from '../lib/format';
import { useDebounced, useUrlFilters } from '../lib/hooks';
import type { InsuranceRequest } from '../lib/types';

const TABS = [
  { value: '', label: 'الكل' },
  { value: 'SUBMITTED', label: 'جديدة' },
  { value: 'IN_REVIEW', label: 'قيد المراجعة' },
  { value: 'QUOTED', label: 'أُرسل عرض سعر' },
  { value: 'COMPLETED', label: 'مكتملة' },
  { value: 'REJECTED', label: 'مرفوضة' },
];

const PRODUCTS = [
  { value: '', label: 'كل المنتجات' },
  { value: 'orange_card', label: 'البطاقة البرتقالية' },
  { value: 'foreign_workers', label: 'العمالة الوافدة' },
  { value: 'medical_liability', label: 'المسؤولية الطبية' },
  { value: 'marine_cargo', label: 'التأمين البحري' },
];

/** Requests for products that staff price and issue manually. */
export function RequestsPage() {
  const { values, page, set } = useUrlFilters(['status', 'product', 'search'] as const);
  const [search, setSearch] = useState(values.search);
  const debounced = useDebounced(search);

  useEffect(() => {
    if (debounced !== values.search) set('search', debounced.trim());
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [debounced]);

  const query = useQuery({
    queryKey: ['requests', { status: values.status, product: values.product, search: values.search, page }],
    queryFn: () =>
      api<InsuranceRequest[]>('/admin/requests', {
        query: { status: values.status, product: values.product, search: values.search, page },
      }),
    placeholderData: keepPreviousData,
  });

  return (
    <>
      <PageHeader title="الطلبات" subtitle="طلبات الإصدار وعروض الأسعار للمنتجات التي تُسعَّر يدويًا" />

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
            <div className="flex w-full flex-wrap gap-2 sm:w-auto">
              <select
                aria-label="المنتج"
                value={values.product}
                onChange={(e) => set('product', e.target.value)}
                className="rounded-xl border border-line bg-white px-3 py-2.5 text-sm"
              >
                {PRODUCTS.map((p) => (
                  <option key={p.value} value={p.value}>
                    {p.label}
                  </option>
                ))}
              </select>
              <Input
                className="w-full sm:w-72"
                placeholder="رقم الطلب، اسم أو هاتف العميل"
                value={search}
                onChange={(e) => setSearch(e.target.value)}
              />
            </div>
          </div>

          {query.isPending ? (
            <Loading />
          ) : query.isError ? (
            <ErrorState message={query.error.message} onRetry={() => query.refetch()} />
          ) : query.data.data.length === 0 ? (
            <EmptyState message="لا توجد طلبات مطابقة" />
          ) : (
            <>
              <Table head={['رقم الطلب', 'المنتج', 'النوع', 'العميل', 'الهاتف', 'التاريخ', 'الحالة']}>
                {query.data.data.map((r) => (
                  <tr key={r.id} className="hover:bg-page/60">
                    <Td>
                      <Link to={`/requests/${r.id}`} className="ltr font-bold text-navy hover:underline">
                        {r.request_no}
                      </Link>
                    </Td>
                    <Td>{r.product.label}</Td>
                    <Td>{r.kind.label}</Td>
                    <Td>{r.customer?.name}</Td>
                    <Td ltr>{r.customer?.phone}</Td>
                    <Td ltr>{formatDateTime(r.created_at)}</Td>
                    <Td>
                      <StatusBadge status={r.status} />
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
