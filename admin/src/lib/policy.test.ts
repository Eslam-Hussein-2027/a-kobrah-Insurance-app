import { describe, expect, it } from 'vitest';
import { policySubject } from './policy';
import type { AdminPolicy } from './types';

const base = {
  id: 1,
  policy_no: 'POL-2026-000001',
  title: '',
  status: { value: 'ACTIVE', label: 'سارية' },
  start_date: '2026-12-01',
  end_date: '2026-12-15',
  premium: '170.00',
  currency: 'LYD',
  issued_at: null,
  customer: null,
  created_at: '2026-11-24T10:00:00+00:00',
} satisfies Omit<AdminPolicy, 'product'>;

describe('policySubject', () => {
  it('describes a motor policy by plate and vehicle', () => {
    const policy: AdminPolicy = {
      ...base,
      product: { value: 'motor', label: 'التأمين الإجباري' },
      vehicle: {
        id: 1,
        plate_no: '5-123456',
        vin: 'X',
        make: 'Toyota',
        model: 'Corolla',
        year: 2019,
        engine_cc: 1600,
        owner_name: 'أحمد الشريف',
        owner_address: 'بنغازي',
        color: { value: 'white', label: 'أبيض' },
        country_of_origin: { value: 'japan', label: 'اليابان' },
        license_purpose: { value: 'private', label: 'خاصة' },
        seats: 5,
        licensing_authority: { value: 'benghazi', label: 'مرور بنغازي' },
        details_complete: true,
      },
    };
    expect(policySubject(policy)).toBe('5-123456 · Toyota Corolla');
  });

  it('describes a travel policy by zone and travellers', () => {
    const policy: AdminPolicy = {
      ...base,
      product: { value: 'travel', label: 'تأمين السفر' },
      vehicle: null,
      travel: {
        zone: { value: 'schengen', label: 'أوروبا (شنغن)' },
        days: 15,
        travellers: [
          { full_name: 'أ', birth_date: '1988-04-12', passport_no: 'LY1' },
          { full_name: 'ب', birth_date: '1991-09-03', passport_no: 'LY2' },
        ],
      },
    };
    expect(policySubject(policy)).toBe('أوروبا (شنغن) · 2 مسافرين');
  });
});
