import 'package:akobrah_insurance/features/catalog/catalog_models.dart';
import 'package:akobrah_insurance/features/persons/person.dart';
import 'package:akobrah_insurance/features/policies/models.dart';
import 'package:akobrah_insurance/features/requests/request_models.dart';
import 'package:akobrah_insurance/features/travel/travel_models.dart';
import 'package:akobrah_insurance/shared/formatters.dart';
import 'package:flutter_test/flutter_test.dart';

/// Payloads copied from the Laravel API responses (backend/tests).
void main() {
  test('Product parses a request product with its form fields', () {
    final product = Product.fromJson({
      'code': 'orange_card',
      'name': 'البطاقة البرتقالية',
      'title': 'البطاقة البرتقالية',
      'description': 'تأمين سيارتك عند السفر بها برًّا…',
      'issuance': 'request',
      'icon': 'card',
      'covers': ['المسؤولية المدنية تجاه الغير خارج ليبيا'],
      'documents': [
        {'key': 'passport', 'label': 'جواز سفر ساري'},
      ],
      'fields': [
        {'key': 'vehicle', 'label': 'المركبة', 'type': 'vehicle', 'required': true, 'min': null, 'max': null},
        {'key': 'duration_days', 'label': 'المدة', 'type': 'integer', 'required': true, 'min': 1, 'max': 365},
      ],
    });

    expect(product.isInstant, isFalse);
    expect(product.fields.first.type, ProductFieldType.vehicle);
    expect(product.fields.last.max, 365);
    expect(product.documents.single.key, 'passport');
  });

  test('Travel policy parses product, title and travellers', () {
    final policy = Policy.fromJson({
      'id': 11,
      'policy_no': 'POL-2026-000011',
      'product': {'value': 'travel', 'label': 'تأمين السفر'},
      'title': 'تأمين السفر - أوروبا (شنغن)',
      'status': {'value': 'ACTIVE', 'label': 'سارية'},
      'start_date': '2026-12-01',
      'end_date': '2026-12-15',
      'premium': '170.00',
      'currency': 'LYD',
      'issued_at': '2026-11-24T10:00:00+00:00',
      'vehicle': null,
      'coverage_type': null,
      'travel': {
        'zone': {'value': 'schengen', 'label': 'أوروبا (شنغن)'},
        'days': 15,
        'travellers': [
          {'full_name': 'أحمد الشريف', 'birth_date': '1988-04-12', 'passport_no': 'LY1234567'},
        ],
      },
      'can_download_pdf': true,
      'verification_url': 'https://app.akobrah.ly/verify/POL-2026-000011/abc',
    });

    expect(policy.isTravel, isTrue);
    expect(policy.isBlocking, isTrue);
    expect(policy.vehicle, isNull);
    expect(policy.travel!.days, 15);
    expect(policy.travel!.travellers.single.passportNo, 'LY1234567');
  });

  test('InsuranceRequest parses details, reply and summary', () {
    final request = InsuranceRequest.fromJson({
      'id': 4,
      'request_no': 'REQ-2026-000042',
      'product': {'value': 'marine_cargo', 'label': 'التأمين البحري'},
      'kind': {'value': 'quote', 'label': 'طلب عرض سعر'},
      'status': {'value': 'QUOTED', 'label': 'وصل عرض السعر'},
      'details': [
        {'key': 'cargo_type', 'label': 'نوع البضاعة', 'value': 'مواد غذائية'},
        {'key': 'destination_port', 'label': 'ميناء الوصول', 'value': 'ميناء بنغازي'},
        {'key': 'cargo_value', 'label': 'قيمة البضاعة', 'value': '250000'},
      ],
      'notes': null,
      'staff_reply': 'السعر شامل الضريبة.',
      'quoted_amount': '1850.00',
      'currency': 'LYD',
      'replied_at': '2026-11-24T12:00:00+00:00',
      'can_cancel': true,
      'documents': [
        {'id': 1, 'key': 'commercial_invoice', 'label': 'الفاتورة التجارية', 'name': 'invoice.pdf'},
      ],
      'created_at': '2026-11-24T10:00:00+00:00',
    });

    expect(request.kind, RequestKind.quote);
    expect(request.status, RequestStatus.quoted);
    expect(request.summary, 'مواد غذائية · ميناء بنغازي');
    expect(request.quotedAmount, '1850.00');
    expect(request.documents.single.name, 'invoice.pdf');
  });

  test('Person without a passport cannot travel', () {
    final person = Person.fromJson({
      'id': 2,
      'full_name': 'سارة محمد',
      'relationship': {'value': 'spouse', 'label': 'الزوج / الزوجة'},
      'birth_date': '1991-09-03',
      'age': 35,
      'passport_no': null,
      'national_id': null,
    });

    expect(person.relationship, Relationship.spouse);
    expect(person.canTravel, isFalse);
  });

  test('TravelSelection totals and end date match the API rules', () {
    const zone = TravelZone(
      value: 'schengen',
      label: 'أوروبا (شنغن)',
      description: '',
      durations: [TravelDuration(days: 7, pricePerTraveller: 60), TravelDuration(days: 15, pricePerTraveller: 85)],
    );
    final travellers = [
      for (final id in [1, 2])
        Person(
          id: id,
          fullName: 'p$id',
          relationship: Relationship.self,
          relationshipLabel: '',
          birthDate: '1990-01-01',
          age: 36,
          passportNo: 'LY$id',
        ),
    ];

    final selection = TravelSelection(
      zone: zone,
      duration: zone.duration(15)!,
      startDate: DateTime(2026, 12, 1),
      travellers: travellers,
    );

    expect(zone.startingPrice, 60);
    expect(amount(selection.total), '170.00');
    expect(isoDate(selection.endDate), '2026-12-15');
  });

  test('formatters: Arabic dates, grouped amounts, masked documents', () {
    expect(formatDateIn('ar', '2027-11-14'), '14 نوفمبر 2027');
    expect(formatDateIn('en', '2027-11-14'), '14 November 2027');
    expect(groupedAmount('1452'), '1,452.00');
    expect(maskDocumentNumber('LY7654321'), '•••• 4321');
    expect(daysUntil('2027-11-14', today: DateTime(2026, 11, 23)), 356);
  });
}
