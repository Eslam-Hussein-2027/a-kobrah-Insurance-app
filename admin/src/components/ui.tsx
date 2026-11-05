import type { ButtonHTMLAttributes, InputHTMLAttributes, ReactNode } from 'react';
import { useEffect } from 'react';
import type { Pagination as PaginationMeta } from '../lib/api';

const cx = (...classes: (string | false | null | undefined)[]) => classes.filter(Boolean).join(' ');

type Variant = 'primary' | 'secondary' | 'danger' | 'ghost';

const VARIANTS: Record<Variant, string> = {
  primary: 'bg-navy text-white hover:bg-navy/90 disabled:bg-navy/50',
  secondary: 'bg-white text-navy border border-line hover:bg-page',
  danger: 'bg-white text-bad border border-bad/40 hover:bg-bad/5',
  ghost: 'text-brand hover:bg-brand/10',
};

export function Button({
  variant = 'primary',
  loading = false,
  className,
  children,
  disabled,
  ...props
}: ButtonHTMLAttributes<HTMLButtonElement> & { variant?: Variant; loading?: boolean }) {
  return (
    <button
      {...props}
      disabled={disabled || loading}
      className={cx(
        'inline-flex items-center justify-center gap-2 rounded-xl px-4 py-2.5 text-sm font-bold transition-colors disabled:cursor-not-allowed',
        VARIANTS[variant],
        className,
      )}
    >
      {loading && <Spinner small />}
      {children}
    </button>
  );
}

export function Input({
  label,
  error,
  ltr,
  className,
  ...props
}: InputHTMLAttributes<HTMLInputElement> & { label?: string; error?: string; ltr?: boolean }) {
  return (
    <label className={cx('block', className)}>
      {label && <span className="mb-1.5 block text-sm font-medium text-slate-700">{label}</span>}
      <input
        {...props}
        dir={ltr ? 'ltr' : undefined}
        className={cx(
          'w-full rounded-xl border bg-white px-3.5 py-2.5 text-sm outline-none transition focus:border-brand focus:ring-2 focus:ring-brand/20',
          ltr && 'text-right',
          error ? 'border-bad' : 'border-line',
        )}
      />
      {error && <span className="mt-1 block text-xs text-bad">{error}</span>}
    </label>
  );
}

export function Card({ title, actions, children, className }: { title?: ReactNode; actions?: ReactNode; children: ReactNode; className?: string }) {
  return (
    <section className={cx('rounded-2xl border border-line bg-white', className)}>
      {(title || actions) && (
        <header className="flex items-center justify-between gap-3 border-b border-line px-5 py-3.5">
          <h2 className="text-base font-bold text-navy">{title}</h2>
          {actions}
        </header>
      )}
      <div className="p-5">{children}</div>
    </section>
  );
}

export type Tone = 'ok' | 'warn' | 'bad' | 'muted' | 'brand';

const TONES: Record<Tone, string> = {
  ok: 'bg-ok/10 text-ok',
  warn: 'bg-warn/10 text-warn',
  bad: 'bg-bad/10 text-bad',
  muted: 'bg-slate-100 text-muted',
  brand: 'bg-brand/10 text-brand',
};

export function Badge({ tone, children }: { tone: Tone; children: ReactNode }) {
  return <span className={cx('inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-bold whitespace-nowrap', TONES[tone])}>{children}</span>;
}

const STATUS_TONES: Record<string, Tone> = {
  ACTIVE: 'ok',
  PAID: 'ok',
  PENDING_PAYMENT: 'warn',
  PENDING: 'warn',
  CANCELLED: 'bad',
  FAILED: 'bad',
  EXPIRED: 'muted',
  REFUNDED: 'muted',
};

export function StatusBadge({ status }: { status: { value: string; label: string } }) {
  return <Badge tone={STATUS_TONES[status.value] ?? 'muted'}>{status.label}</Badge>;
}

export function Spinner({ small = false }: { small?: boolean }) {
  return (
    <span
      className={cx('inline-block animate-spin rounded-full border-2 border-current border-t-transparent', small ? 'size-4' : 'size-8 text-brand')}
      aria-label="جارٍ التحميل"
    />
  );
}

export function Loading() {
  return (
    <div className="flex justify-center py-16">
      <Spinner />
    </div>
  );
}

export function ErrorState({ message, onRetry }: { message: string; onRetry?: () => void }) {
  return (
    <div className="flex flex-col items-center gap-3 py-12 text-center">
      <p className="text-bad">{message}</p>
      {onRetry && (
        <Button variant="secondary" onClick={onRetry}>
          إعادة المحاولة
        </Button>
      )}
    </div>
  );
}

export function EmptyState({ message }: { message: string }) {
  return <p className="py-12 text-center text-muted">{message}</p>;
}

export function Pagination({ meta, onChange }: { meta?: PaginationMeta; onChange: (page: number) => void }) {
  if (!meta || meta.last_page <= 1) return null;
  return (
    <div className="flex items-center justify-between border-t border-line px-5 py-3 text-sm text-muted">
      <span>
        صفحة <span className="ltr">{meta.current_page}</span> من <span className="ltr">{meta.last_page}</span> (
        <span className="ltr">{meta.total}</span> نتيجة)
      </span>
      <div className="flex gap-2">
        <Button variant="secondary" disabled={meta.current_page <= 1} onClick={() => onChange(meta.current_page - 1)}>
          السابق
        </Button>
        <Button variant="secondary" disabled={meta.current_page >= meta.last_page} onClick={() => onChange(meta.current_page + 1)}>
          التالي
        </Button>
      </div>
    </div>
  );
}

export function Modal({ open, title, onClose, children }: { open: boolean; title: string; onClose: () => void; children: ReactNode }) {
  useEffect(() => {
    if (!open) return;
    const onKey = (e: KeyboardEvent) => e.key === 'Escape' && onClose();
    window.addEventListener('keydown', onKey);
    return () => window.removeEventListener('keydown', onKey);
  }, [open, onClose]);

  if (!open) return null;
  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-slate-900/40 p-4" onClick={onClose}>
      <div role="dialog" aria-modal="true" className="w-full max-w-md rounded-2xl bg-white shadow-xl" onClick={(e) => e.stopPropagation()}>
        <header className="border-b border-line px-5 py-4 text-lg font-bold text-navy">{title}</header>
        <div className="p-5">{children}</div>
      </div>
    </div>
  );
}

export function PageHeader({ title, subtitle, actions }: { title: string; subtitle?: string; actions?: ReactNode }) {
  return (
    <div className="mb-6 flex flex-wrap items-end justify-between gap-4">
      <div>
        <h1 className="text-2xl font-bold text-navy">{title}</h1>
        {subtitle && <p className="mt-1 text-muted">{subtitle}</p>}
      </div>
      {actions}
    </div>
  );
}

export function Field({ label, children }: { label: string; children: ReactNode }) {
  return (
    <div className="flex items-start justify-between gap-4 border-b border-line/70 py-2.5 last:border-0">
      <span className="text-sm text-muted">{label}</span>
      <span className="text-end text-sm font-semibold">{children}</span>
    </div>
  );
}

export function Table({ head, children }: { head: string[]; children: ReactNode }) {
  return (
    <div className="overflow-x-auto">
      <table className="w-full text-sm">
        <thead>
          <tr className="border-b border-line bg-page/60 text-muted">
            {head.map((h) => (
              <th key={h} className="px-4 py-3 text-start font-medium whitespace-nowrap">
                {h}
              </th>
            ))}
          </tr>
        </thead>
        <tbody className="divide-y divide-line">{children}</tbody>
      </table>
    </div>
  );
}

export function Td({ children, ltr, className }: { children: ReactNode; ltr?: boolean; className?: string }) {
  return (
    <td className={cx('px-4 py-3 whitespace-nowrap', className)}>
      {ltr ? <span className="ltr">{children}</span> : children}
    </td>
  );
}
