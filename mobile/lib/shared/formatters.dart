import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/l10n.dart';

const _arabicMonths = [
  'يناير',
  'فبراير',
  'مارس',
  'أبريل',
  'مايو',
  'يونيو',
  'يوليو',
  'أغسطس',
  'سبتمبر',
  'أكتوبر',
  'نوفمبر',
  'ديسمبر',
];

const _englishMonths = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

/// "2027-11-14" → "14 نوفمبر 2027" / "14 November 2027" (Western digits, as used in Libya).
String formatDate(BuildContext context, String isoDate) =>
    formatDateIn(Localizations.localeOf(context).languageCode, isoDate);

String formatDateIn(String languageCode, String isoDate) {
  final date = DateTime.tryParse(isoDate);
  if (date == null) return isoDate;
  // Timestamps ("2026-11-24T05:00:00+00:00") are shown in the phone's time zone.
  final local = isoDate.length > 10 ? date.toLocal() : date;
  final months = languageCode == 'ar' ? _arabicMonths : _englishMonths;
  return '${local.day} ${months[local.month - 1]} ${local.year}';
}

/// API date format.
String isoDate(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

final _moneyFormat = NumberFormat('#,##0.00', 'en');

/// "1452.00" → "1,452.00 د.ل"
String formatMoney(BuildContext context, String amount) => '${groupedAmount(amount)} ${context.l10n.currency}';

/// "1452" → "1,452.00"
String groupedAmount(String amount) {
  final value = double.tryParse(amount);
  return value == null ? amount : _moneyFormat.format(value);
}

/// "LY7654321" → "•••• 4321": enough to recognise a document without showing it in full.
String maskDocumentNumber(String value) => value.length <= 4 ? value : '•••• ${value.substring(value.length - 4)}';

/// Whole days from today until [isoDate] (negative when past).
int daysUntil(String isoDate, {DateTime? today}) {
  final date = DateTime.tryParse(isoDate);
  if (date == null) return 0;
  final now = DateUtils.dateOnly(today ?? DateTime.now());
  return DateUtils.dateOnly(date).difference(now).inDays;
}
