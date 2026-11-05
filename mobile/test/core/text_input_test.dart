import 'package:akobrah_insurance/core/text_input.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('normalizeLibyanPhone', () {
    test('converts international and Arabic-digit formats to local 09XXXXXXXX', () {
      for (final input in [
        '+218911234567',
        '00218911234567',
        '218911234567',
        '+218 91-123 4567',
        '٠٩١١٢٣٤٥٦٧',
        '091 123 4567',
      ]) {
        expect(normalizeLibyanPhone(input), '0911234567', reason: input);
      }
    });

    test('keeps a local number as is', () {
      expect(normalizeLibyanPhone('0925441206'), '0925441206');
    });
  });

  test('toWesternDigits converts Arabic-Indic and Persian digits only', () {
    expect(toWesternDigits('٢٠٢٦-١١-٠٥'), '2026-11-05');
    expect(toWesternDigits('۱۲۳ abc'), '123 abc');
  });
}
