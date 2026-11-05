import 'package:akobrah_insurance/features/auth/models.dart';
import 'package:akobrah_insurance/features/policies/models.dart';
import 'package:flutter_test/flutter_test.dart';

/// Payloads copied from the Laravel API (backend/) responses.
void main() {
  test('AppUser parses /auth/me', () {
    final user = AppUser.fromJson({
      'id': 3,
      'name': 'محمد العميل',
      'phone': '0910000003',
      'national_id': '119950000033',
      'role': {'value': 'customer', 'label': 'عميل'},
      'phone_verified_at': '2026-11-05T18:00:00+00:00',
      'documents': {
        'id_image': {'uploaded': true, 'url': 'https://example.test/signed'},
        'license_image': {'uploaded': false, 'url': null},
      },
      'kyc_completed': false,
      'created_at': '2026-11-05T18:00:00+00:00',
    });

    expect(user.isCustomer, isTrue);
    expect(user.idImage.uploaded, isTrue);
    expect(user.idImage.url, isNotNull);
    expect(user.licenseImage.uploaded, isFalse);
    expect(user.kycCompleted, isFalse);
  });

  test('Policy parses status, nested vehicle and coverage', () {
    final policy = Policy.fromJson({
      'id': 1,
      'policy_no': 'POL-2026-000001',
      'status': {'value': 'PENDING_PAYMENT', 'label': 'بانتظار الدفع'},
      'start_date': '2026-11-05',
      'end_date': '2027-11-04',
      'premium': '1452.00',
      'currency': 'LYD',
      'issued_at': null,
      'previous_policy_id': null,
      'vehicle': {
        'id': 1,
        'plate_no': '5-123456',
        'vin': 'JTDBR32E720123456',
        'make': 'Toyota',
        'model': 'Corolla',
        'year': 2019,
        'engine_cc': 1600,
        'age_years': 7,
      },
      'coverage_type': {
        'id': 1,
        'code': 'THIRD_PARTY',
        'name': 'التأمين الإجباري (ضد الغير)',
        'description': null,
        'base_price': '1200.00',
        'currency': 'LYD',
        'is_mandatory': true,
      },
      'can_download_pdf': false,
      'created_at': '2026-11-05T18:00:00+00:00',
    });

    expect(policy.status, PolicyStatus.pendingPayment);
    expect(policy.statusLabel, 'بانتظار الدفع');
    expect(policy.vehicle!.plateNo, '5-123456');
    expect(policy.coverageType!.isMandatory, isTrue);
    expect(policy.canDownloadPdf, isFalse);
  });

  test('Quote parses factor breakdown', () {
    final quote = Quote.fromJson({
      'base_price': '1200.00',
      'factors': [
        {'type': 'vehicle_age', 'label': 'عمر المركبة', 'input': 7, 'multiplier': '1.100'},
        {'type': 'engine_cc', 'label': 'سعة المحرك', 'input': 1600, 'multiplier': '1.100'},
        {'type': 'claims_history', 'label': 'سجل المطالبات', 'input': 0, 'multiplier': '1.000'},
      ],
      'premium': '1452.00',
      'currency': 'LYD',
    });

    expect(quote.factors, hasLength(3));
    expect(quote.factors.first.label, 'عمر المركبة');
    expect(quote.premium, '1452.00');
  });

  test('unknown policy status does not crash', () {
    expect(PolicyStatus.fromValue('SOMETHING_NEW'), PolicyStatus.unknown);
  });

  test('OnlinePayment parses pending and paid payments', () {
    final pending = OnlinePayment.fromJson({
      'id': 5,
      'status': {'value': 'PENDING', 'label': 'قيد الانتظار'},
      'checkout_url': 'https://pay.example/checkout/5',
    });
    expect(pending.checkoutUrl, isNotNull);
    expect(pending.isPaid, isFalse);

    final paid = OnlinePayment.fromJson({
      'id': 5,
      'status': {'value': 'PAID', 'label': 'مدفوع'},
    });
    expect(paid.isPaid, isTrue);
    expect(paid.checkoutUrl, isNull);
  });
}
