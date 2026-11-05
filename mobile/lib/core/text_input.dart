/// Input helpers for Arabic keyboards and Libyan formats.
library;

const _arabicDigits = {
  '٠': '0',
  '١': '1',
  '٢': '2',
  '٣': '3',
  '٤': '4',
  '٥': '5',
  '٦': '6',
  '٧': '7',
  '٨': '8',
  '٩': '9',
  '۰': '0',
  '۱': '1',
  '۲': '2',
  '۳': '3',
  '۴': '4',
  '۵': '5',
  '۶': '6',
  '۷': '7',
  '۸': '8',
  '۹': '9',
};

/// Converts Eastern Arabic / Persian digits to Western digits.
String toWesternDigits(String input) {
  final buffer = StringBuffer();
  for (final char in input.split('')) {
    buffer.write(_arabicDigits[char] ?? char);
  }
  return buffer.toString();
}

/// "+218 91-123 4567", "00218911234567", "٠٩١١٢٣٤٥٦٧" → "0911234567".
String normalizeLibyanPhone(String input) {
  var phone = toWesternDigits(input).replaceAll(RegExp(r'[\s\-().]'), '');

  for (final prefix in ['+218', '00218']) {
    if (phone.startsWith(prefix)) {
      return '0${phone.substring(prefix.length)}';
    }
  }

  if (phone.startsWith('218') && phone.length == 12) {
    phone = '0${phone.substring(3)}';
  }

  return phone;
}
