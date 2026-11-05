import { useMutation, useQueryClient } from '@tanstack/react-query';
import { useState } from 'react';
import { ApiError, api, openProtectedFile } from '../lib/api';
import { formatMoney } from '../lib/format';
import type { AdminPolicy } from '../lib/types';
import { useToast } from './toast';
import { Button, Input, Modal } from './ui';

/** "Pay at office": records the cash/POS payment and activates the policy. */
export function ConfirmPaymentButton({ policy, compact = false }: { policy: AdminPolicy; compact?: boolean }) {
  const toast = useToast();
  const queryClient = useQueryClient();
  const [open, setOpen] = useState(false);
  const [reference, setReference] = useState('');

  const mutation = useMutation({
    mutationFn: () =>
      api<AdminPolicy>(`/admin/policies/${policy.id}/confirm-office-payment`, {
        method: 'POST',
        body: { reference: reference.trim() || null },
      }),
    onSuccess: (res) => {
      toast(res.message ?? 'تم تأكيد الدفع');
      setOpen(false);
      setReference('');
      void queryClient.invalidateQueries();
    },
    onError: (e: ApiError) => toast(e.message, 'error'),
  });

  return (
    <>
      <Button onClick={() => setOpen(true)} className={compact ? 'px-3 py-1.5 text-xs' : undefined}>
        تأكيد الدفع في المكتب
      </Button>
      <Modal open={open} title="تأكيد الدفع في المكتب" onClose={() => setOpen(false)}>
        <p className="text-sm text-slate-700">
          الوثيقة <span className="ltr font-bold">{policy.policy_no}</span> - القسط{' '}
          <span className="whitespace-nowrap font-bold text-navy">{formatMoney(policy.premium)}</span>
        </p>
        <p className="mt-2 text-sm text-muted">بعد التأكيد تصبح الوثيقة سارية ويستطيع العميل تحميلها من التطبيق.</p>
        <Input className="mt-4" label="رقم الإيصال (اختياري)" ltr value={reference} onChange={(e) => setReference(e.target.value)} />
        <div className="mt-6 flex gap-3">
          <Button loading={mutation.isPending} onClick={() => mutation.mutate()} className="flex-1">
            تأكيد استلام المبلغ
          </Button>
          <Button variant="secondary" onClick={() => setOpen(false)}>
            إلغاء
          </Button>
        </div>
      </Modal>
    </>
  );
}

export function PrintPolicyButton({ policy }: { policy: AdminPolicy }) {
  const toast = useToast();
  const [loading, setLoading] = useState(false);

  const print = async () => {
    setLoading(true);
    try {
      await openProtectedFile(`/admin/policies/${policy.id}/pdf`);
    } catch (e) {
      toast(e instanceof ApiError ? e.message : 'تعذّر فتح الوثيقة', 'error');
    } finally {
      setLoading(false);
    }
  };

  return (
    <Button variant="secondary" loading={loading} onClick={print}>
      طباعة الوثيقة (PDF)
    </Button>
  );
}

export function CancelPolicyButton({ policy }: { policy: AdminPolicy }) {
  const toast = useToast();
  const queryClient = useQueryClient();
  const [open, setOpen] = useState(false);

  const mutation = useMutation({
    mutationFn: () => api<AdminPolicy>(`/admin/policies/${policy.id}/cancel`, { method: 'POST' }),
    onSuccess: (res) => {
      toast(res.message ?? 'تم الإلغاء');
      setOpen(false);
      void queryClient.invalidateQueries();
    },
    onError: (e: ApiError) => toast(e.message, 'error'),
  });

  return (
    <>
      <Button variant="danger" onClick={() => setOpen(true)}>
        إلغاء الوثيقة
      </Button>
      <Modal open={open} title="إلغاء الوثيقة" onClose={() => setOpen(false)}>
        <p className="text-sm">
          هل تريد إلغاء الوثيقة <span className="ltr font-bold">{policy.policy_no}</span>؟ لا يمكن التراجع عن هذا الإجراء.
        </p>
        <div className="mt-6 flex gap-3">
          <Button variant="danger" loading={mutation.isPending} onClick={() => mutation.mutate()} className="flex-1">
            نعم، إلغاء الوثيقة
          </Button>
          <Button variant="secondary" onClick={() => setOpen(false)}>
            تراجع
          </Button>
        </div>
      </Modal>
    </>
  );
}
