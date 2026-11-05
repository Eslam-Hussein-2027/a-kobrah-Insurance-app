import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { Fragment, useState } from 'react';
import { useToast } from '../components/toast';
import { Badge, Button, Card, ErrorState, Input, Loading, PageHeader, Table, Td } from '../components/ui';
import type { ApiError } from '../lib/api';
import { api } from '../lib/api';
import { formatMoney, rangeLabel } from '../lib/format';
import type { CoverageType, FactorType, Pricing, PricingFactor } from '../lib/types';

const UNITS: Record<FactorType, string> = {
  vehicle_age: 'سنة',
  engine_cc: 'سي سي',
  claims_history: 'مطالبة',
};

const HINTS: Record<FactorType, string> = {
  vehicle_age: 'عمر المركبة = السنة الحالية - سنة الصنع',
  engine_cc: 'سعة المحرك بالسنتيمتر المكعب',
  claims_history: 'عدد مطالبات العميل غير المرفوضة خلال آخر 3 سنوات',
};

function useInvalidatePricing() {
  const queryClient = useQueryClient();
  return () => queryClient.invalidateQueries({ queryKey: ['pricing'] });
}

function CoverageCard({ coverage }: { coverage: CoverageType }) {
  const toast = useToast();
  const invalidate = useInvalidatePricing();
  const [price, setPrice] = useState(coverage.base_price);

  const save = useMutation({
    mutationFn: (body: Partial<CoverageType>) => api<CoverageType>(`/admin/coverage-types/${coverage.id}`, { method: 'PATCH', body }),
    onSuccess: (res) => {
      toast(res.message ?? 'تم الحفظ');
      void invalidate();
    },
    onError: (e: ApiError) => toast(e.field('base_price') ?? e.message, 'error'),
  });

  return (
    <div className={`rounded-2xl border p-5 ${coverage.is_active ? 'border-line bg-white' : 'border-dashed border-line bg-page'}`}>
      <div className="flex items-start justify-between gap-3">
        <div>
          <p className="font-bold text-navy">{coverage.name}</p>
          <p className="mt-1 text-xs text-muted">{coverage.description}</p>
        </div>
        {coverage.is_active ? <Badge tone="ok">متاح للعملاء</Badge> : <Badge tone="muted">غير متاح</Badge>}
      </div>
      <div className="mt-4 flex items-end gap-2">
        <Input className="flex-1" label="السعر الأساسي (دينار ليبي)" ltr type="number" min="0" step="0.01" value={price} onChange={(e) => setPrice(e.target.value)} />
        <Button loading={save.isPending} disabled={price === coverage.base_price || price === ''} onClick={() => save.mutate({ base_price: price })}>
          حفظ
        </Button>
      </div>
      <button
        className="mt-3 text-sm font-bold text-brand hover:underline"
        onClick={() => save.mutate({ is_active: !coverage.is_active })}
        disabled={save.isPending}
      >
        {coverage.is_active ? 'إيقاف هذا النوع' : 'إتاحة هذا النوع للعملاء'}
      </button>
    </div>
  );
}

interface BandForm {
  min_value: string;
  max_value: string;
  multiplier: string;
}

const emptyForm: BandForm = { min_value: '', max_value: '', multiplier: '' };

function FactorSection({ type, label, bands, gaps }: { type: FactorType; label: string; bands: PricingFactor[]; gaps: string[] }) {
  const toast = useToast();
  const invalidate = useInvalidatePricing();
  const [editing, setEditing] = useState<number | 'new' | null>(null);
  const [form, setForm] = useState<BandForm>(emptyForm);

  const save = useMutation({
    mutationFn: () => {
      const body = {
        factor_type: type,
        min_value: Number(form.min_value),
        max_value: form.max_value === '' ? null : Number(form.max_value),
        multiplier: Number(form.multiplier),
      };
      return editing === 'new'
        ? api('/admin/pricing-factors', { method: 'POST', body })
        : api(`/admin/pricing-factors/${editing}`, { method: 'PUT', body });
    },
    onSuccess: (res) => {
      toast(res.message ?? 'تم الحفظ');
      setEditing(null);
      void invalidate();
    },
    onError: (e: ApiError) => toast(e.field('max_value') ?? e.field('multiplier') ?? e.field('min_value') ?? e.message, 'error'),
  });

  const remove = useMutation({
    mutationFn: (id: number) => api(`/admin/pricing-factors/${id}`, { method: 'DELETE' }),
    onSuccess: (res) => {
      toast(res.message ?? 'تم الحذف');
      void invalidate();
    },
    onError: (e: ApiError) => toast(e.message, 'error'),
  });

  const startEdit = (band: PricingFactor) => {
    setEditing(band.id);
    setForm({ min_value: String(band.min_value), max_value: band.max_value === null ? '' : String(band.max_value), multiplier: band.multiplier });
  };

  const formRow = (
    <tr className="bg-brand/5">
      <Td>
        <input aria-label="من" dir="ltr" type="number" min="0" className="w-24 rounded-lg border border-line px-2 py-1.5" value={form.min_value} onChange={(e) => setForm({ ...form, min_value: e.target.value })} />
      </Td>
      <Td>
        <input aria-label="إلى" dir="ltr" type="number" min="0" placeholder="بدون حد" className="w-24 rounded-lg border border-line px-2 py-1.5" value={form.max_value} onChange={(e) => setForm({ ...form, max_value: e.target.value })} />
      </Td>
      <Td>
        <input aria-label="المعامل" dir="ltr" type="number" min="0.1" step="0.001" className="w-24 rounded-lg border border-line px-2 py-1.5" value={form.multiplier} onChange={(e) => setForm({ ...form, multiplier: e.target.value })} />
      </Td>
      <Td>—</Td>
      <Td className="text-end">
        <div className="flex justify-end gap-2">
          <Button className="px-3 py-1.5 text-xs" loading={save.isPending} onClick={() => save.mutate()}>
            حفظ
          </Button>
          <Button variant="secondary" className="px-3 py-1.5 text-xs" onClick={() => setEditing(null)}>
            إلغاء
          </Button>
        </div>
      </Td>
    </tr>
  );

  return (
    <Card
      title={label}
      actions={
        <Button
          variant="ghost"
          onClick={() => {
            setEditing('new');
            setForm(emptyForm);
          }}
        >
          + إضافة شريحة
        </Button>
      }
    >
      <p className="-mt-1 mb-3 text-xs text-muted">{HINTS[type]}</p>
      {gaps.length > 0 && (
        <p className="mb-3 rounded-xl bg-bad/10 px-3 py-2 text-sm text-bad">
          قيم بدون معامل (لن يتمكن العملاء من الحصول على سعر لها):{' '}
          {gaps.map((g) => (
            <span key={g} className="ltr mx-1 font-bold">
              {g}
            </span>
          ))}
        </p>
      )}
      <div className="-mx-5 -mb-5">
        <Table head={[`من (${UNITS[type]})`, 'إلى', 'المعامل', 'الأثر على السعر', '']}>
          {bands.map((band) =>
            editing === band.id ? (
              <Fragment key={band.id}>{formRow}</Fragment>
            ) : (
              <tr key={band.id}>
                <Td ltr>{band.min_value}</Td>
                <Td>{band.max_value === null ? 'فأكثر' : <span className="ltr">{band.max_value}</span>}</Td>
                <Td ltr>× {band.multiplier}</Td>
                <Td>
                  <EffectBadge multiplier={Number(band.multiplier)} />
                </Td>
                <Td className="text-end">
                  <div className="flex justify-end gap-3">
                    <button className="text-sm font-bold text-brand hover:underline" onClick={() => startEdit(band)}>
                      تعديل
                    </button>
                    <button
                      className="text-sm font-bold text-bad hover:underline"
                      onClick={() => window.confirm(`حذف الشريحة ${rangeLabel(band.min_value, band.max_value)}؟`) && remove.mutate(band.id)}
                    >
                      حذف
                    </button>
                  </div>
                </Td>
              </tr>
            ),
          )}
          {editing === 'new' && formRow}
        </Table>
      </div>
    </Card>
  );
}

function EffectBadge({ multiplier }: { multiplier: number }) {
  const pct = Math.round((multiplier - 1) * 1000) / 10;
  if (pct === 0) return <Badge tone="muted">بدون تغيير</Badge>;
  return pct > 0 ? <Badge tone="warn">{`زيادة ${pct}%`}</Badge> : <Badge tone="ok">{`خصم ${Math.abs(pct)}%`}</Badge>;
}

export function PricingPage() {
  const query = useQuery({ queryKey: ['pricing'], queryFn: () => api<Pricing>('/admin/pricing').then((r) => r.data) });

  if (query.isPending) return <Loading />;
  if (query.isError) return <ErrorState message={query.error.message} onRetry={() => query.refetch()} />;
  const pricing = query.data;
  const example = pricing.coverage_types.find((c) => c.is_active);

  return (
    <>
      <PageHeader
        title="التسعير"
        subtitle="القسط = السعر الأساسي × معامل عمر المركبة × معامل سعة المحرك × معامل سجل المطالبات. التغييرات تسري على الأسعار الجديدة فقط."
      />

      <div className="grid gap-4 md:grid-cols-2">
        {pricing.coverage_types.map((c) => (
          <CoverageCard key={`${c.id}-${c.base_price}-${String(c.is_active)}`} coverage={c} />
        ))}
      </div>

      {example && (
        <p className="mt-4 text-sm text-muted">
          مثال: سيارة جديدة بمحرك صغير وبدون مطالبات تدفع السعر الأساسي{' '}
          <span className="whitespace-nowrap font-bold text-navy">{formatMoney(example.base_price)}</span>.
        </p>
      )}

      <div className="mt-6 grid gap-6 min-[1800px]:grid-cols-3">
        {pricing.factor_types.map((t) => (
          <FactorSection
            key={t.value}
            type={t.value}
            label={t.label}
            bands={pricing.factors.filter((f) => f.factor_type.value === t.value)}
            gaps={pricing.gaps[t.value] ?? []}
          />
        ))}
      </div>
    </>
  );
}
