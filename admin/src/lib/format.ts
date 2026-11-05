const MONTHS = ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو', 'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'];

/** "1452.5" → "1,452.50 د.ل" (Western digits, as used across the platform). */
export function formatMoney(amount: string | number, currency = 'د.ل'): string {
  const value = Number(amount);
  const formatted = (Number.isFinite(value) ? value : 0).toLocaleString('en-US', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2,
  });
  return `${formatted} ${currency}`;
}

/** ISO date/datetime → "2026-11-05". */
export function formatDate(iso: string | null | undefined): string {
  return iso ? iso.slice(0, 10) : '—';
}

/** ISO datetime → "2026-11-05 14:30" in the viewer's local time. */
export function formatDateTime(iso: string | null | undefined): string {
  if (!iso) return '—';
  const d = new Date(iso);
  if (Number.isNaN(d.getTime())) return iso;
  const pad = (n: number) => String(n).padStart(2, '0');
  return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())} ${pad(d.getHours())}:${pad(d.getMinutes())}`;
}

/** "2026-06" → "يونيو" */
export function monthName(key: string): string {
  const month = Number(key.split('-')[1]);
  return MONTHS[month - 1] ?? key;
}

/** Pricing band label: "4 - 7", "21 فأكثر". */
export function rangeLabel(min: number, max: number | null): string {
  return max === null ? `${min} فأكثر` : `${min} - ${max}`;
}

const FAILURE_REASONS: Record<string, string> = {
  declined: 'رُفضت من مزوّد الدفع',
  superseded: 'استُبدلت بمحاولة أحدث',
  paid_at_office: 'دُفعت في المكتب',
  amount_mismatch: 'المبلغ المدفوع غير مطابق',
};

export function failureReasonLabel(reason: string | null): string | null {
  return reason ? (FAILURE_REASONS[reason] ?? reason) : null;
}
