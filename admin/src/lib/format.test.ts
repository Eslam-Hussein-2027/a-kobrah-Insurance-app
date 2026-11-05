import { describe, expect, it } from 'vitest';
import { ApiError, toApiError } from './api';
import { failureReasonLabel, formatDate, formatMoney, monthName, rangeLabel } from './format';

describe('format', () => {
  it('formats money with Western digits and dinar symbol', () => {
    expect(formatMoney('1452')).toBe('1,452.00 د.ل');
    expect(formatMoney(7865.5)).toBe('7,865.50 د.ل');
    expect(formatMoney('not-a-number')).toBe('0.00 د.ل');
  });

  it('formats dates and months', () => {
    expect(formatDate('2026-11-05T18:00:00+00:00')).toBe('2026-11-05');
    expect(formatDate(null)).toBe('—');
    expect(monthName('2026-06')).toBe('يونيو');
    expect(monthName('2026-12')).toBe('ديسمبر');
  });

  it('labels pricing bands and payment failures', () => {
    expect(rangeLabel(4, 7)).toBe('4 - 7');
    expect(rangeLabel(21, null)).toBe('21 فأكثر');
    expect(failureReasonLabel('paid_at_office')).toBe('دُفعت في المكتب');
    expect(failureReasonLabel(null)).toBeNull();
  });
});

describe('toApiError', () => {
  it('keeps the server message and field errors', () => {
    const error = toApiError(422, {
      success: false,
      message: 'البيانات المدخلة غير صحيحة.',
      errors: { phone: ['رقم الهاتف أو كلمة المرور غير صحيحة.'] },
    });

    expect(error).toBeInstanceOf(ApiError);
    expect(error.status).toBe(422);
    expect(error.message).toBe('البيانات المدخلة غير صحيحة.');
    expect(error.field('phone')).toBe('رقم الهاتف أو كلمة المرور غير صحيحة.');
    expect(error.field('password')).toBeUndefined();
  });

  it('falls back to a generic Arabic message', () => {
    expect(toApiError(500, null).message).toBe('حدث خطأ غير متوقع، حاول مرة أخرى.');
  });
});
