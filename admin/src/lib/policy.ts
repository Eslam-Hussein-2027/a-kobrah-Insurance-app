import type { AdminPolicy } from './types';

/** What a policy covers, in one line: "5-123456 · Toyota Corolla" or "أوروبا (شنغن) · 2 مسافر". */
export function policySubject(policy: AdminPolicy): string {
  if (policy.travel) {
    const count = policy.travel.travellers.length;
    return `${policy.travel.zone?.label ?? ''} · ${count} ${count === 1 ? 'مسافر' : 'مسافرين'}`;
  }
  if (policy.vehicle) {
    return `${policy.vehicle.plate_no} · ${policy.vehicle.make} ${policy.vehicle.model}`;
  }
  return '—';
}
