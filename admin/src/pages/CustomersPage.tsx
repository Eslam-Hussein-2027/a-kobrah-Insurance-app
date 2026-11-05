import { keepPreviousData, useQuery } from '@tanstack/react-query';
import { useEffect, useState } from 'react';
import { Link } from 'react-router';
import { Badge, Card, EmptyState, ErrorState, Input, Loading, PageHeader, Pagination, Table, Td } from '../components/ui';
import { api } from '../lib/api';
import { formatDate } from '../lib/format';
import { useDebounced, useUrlFilters } from '../lib/hooks';
import type { Customer } from '../lib/types';

export function CustomersPage() {
  const { values, page, set } = useUrlFilters(['search'] as const);
  const [search, setSearch] = useState(values.search);
  const debounced = useDebounced(search);

  useEffect(() => {
    if (debounced !== values.search) set('search', debounced.trim());
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [debounced]);

  const query = useQuery({
    queryKey: ['customers', values.search, page],
    queryFn: () => api<Customer[]>('/admin/customers', { query: { search: values.search, page } }),
    placeholderData: keepPreviousData,
  });

  return (
    <>
      <PageHeader title="العملاء" subtitle="العملاء المسجلون في التطبيق" />

      <Card>
        <div className="-m-5">
          <div className="border-b border-line p-4">
            <Input className="w-full sm:w-80" placeholder="بحث بالاسم أو الهاتف أو الرقم الوطني" value={search} onChange={(e) => setSearch(e.target.value)} />
          </div>

          {query.isPending ? (
            <Loading />
          ) : query.isError ? (
            <ErrorState message={query.error.message} onRetry={() => query.refetch()} />
          ) : query.data.data.length === 0 ? (
            <EmptyState message="لا يوجد عملاء مطابقون" />
          ) : (
            <>
              <Table head={['الاسم', 'الهاتف', 'الرقم الوطني', 'المركبات', 'الوثائق', 'المستندات', 'الحساب', 'تاريخ التسجيل']}>
                {query.data.data.map((c) => (
                  <tr key={c.id} className="hover:bg-page/60">
                    <Td>
                      <Link to={`/customers/${c.id}`} className="font-bold text-navy hover:underline">
                        {c.name}
                      </Link>
                    </Td>
                    <Td ltr>{c.phone}</Td>
                    <Td ltr>{c.national_id ?? '—'}</Td>
                    <Td ltr>{c.vehicles_count ?? 0}</Td>
                    <Td ltr>{c.policies_count ?? 0}</Td>
                    <Td>{c.kyc_completed ? <Badge tone="ok">مكتملة</Badge> : <Badge tone="warn">ناقصة</Badge>}</Td>
                    <Td>{c.is_active ? <Badge tone="ok">نشط</Badge> : <Badge tone="bad">موقوف</Badge>}</Td>
                    <Td ltr>{formatDate(c.created_at)}</Td>
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
