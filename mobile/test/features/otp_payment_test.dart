import 'package:akobrah_insurance/core/api/api_client.dart';
import 'package:akobrah_insurance/core/api/api_exception.dart';
import 'package:akobrah_insurance/core/l10n.dart';
import 'package:akobrah_insurance/core/storage.dart';
import 'package:akobrah_insurance/core/theme.dart';
import 'package:akobrah_insurance/features/policies/models.dart';
import 'package:akobrah_insurance/features/policies/otp_payment_sheet.dart';
import 'package:akobrah_insurance/features/policies/policies_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// DPAY sandbox rules: 111111 settles, 000000 declines, anything else is a wrong code.
class FakePaymentsRepository extends PoliciesRepository {
  FakePaymentsRepository() : super(ApiClient(Dio()));

  final List<({String? phone, String? payMethod})> started = [];

  @override
  Future<OnlinePayment> payOnline(int policyId, {String? phone, String? payMethod}) async {
    started.add((phone: phone, payMethod: payMethod));
    return const OnlinePayment(id: 7, status: 'PENDING', statusLabel: 'قيد الانتظار', requiresOtp: true);
  }

  @override
  Future<({OnlinePayment payment, String? message})> confirmPayment(int paymentId, String otp) async {
    return switch (otp) {
      '111111' => (payment: const OnlinePayment(id: 7, status: 'PAID', statusLabel: 'مدفوع'), message: null),
      '000000' => (
        payment: const OnlinePayment(id: 7, status: 'FAILED', statusLabel: 'فشل الدفع'),
        message: 'لم تتم عملية الدفع، يمكنك المحاولة مرة أخرى.',
      ),
      _ => throw const ApiException(ApiErrorKind.validation, message: 'رمز التحقق غير صحيح، حاول مرة أخرى.'),
    };
  }
}

const _policy = Policy(
  id: 10,
  policyNo: 'POL-2026-000010',
  product: 'motor',
  productName: 'التأمين الإجباري',
  title: 'التأمين الإجباري (ضد الغير)',
  status: PolicyStatus.pendingPayment,
  statusLabel: 'بانتظار الدفع',
  startDate: '2026-11-27',
  endDate: '2027-11-26',
  premium: '1452.00',
  canDownloadPdf: false,
);

const _options = PaymentOptions(
  flow: 'otp',
  methods: [(value: 'edfali', label: 'إدفعلي'), (value: 'sadad', label: 'سداد')],
);

Future<({FakePaymentsRepository repository, ValueNotifier<bool?> result})> _pump(WidgetTester tester) async {
  final repository = FakePaymentsRepository();
  final result = ValueNotifier<bool?>(null);
  await tester.binding.setSurfaceSize(const Size(420, 900));
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        keyValueStoreProvider.overrideWithValue(MemoryKeyValueStore()),
        policiesRepositoryProvider.overrideWithValue(repository),
      ],
      child: MaterialApp(
        theme: AppTheme.light(),
        locale: const Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: FilledButton(
                onPressed: () async => result.value = await showModalBottomSheet<bool>(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => const OtpPaymentSheet(policy: _policy, options: _options),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  return (repository: repository, result: result);
}

void main() {
  testWidgets('phone → code → paid closes the sheet with success', (tester) async {
    final (:repository, :result) = await _pump(tester);

    await tester.tap(find.text('سداد'));
    await tester.enterText(find.byType(TextField), '+218 91 123 4567');
    await tester.tap(find.text('إرسال رمز التحقق'));
    await tester.pumpAndSettle();

    expect(repository.started.single, (phone: '0911234567', payMethod: 'sadad'));
    expect(find.text('تأكيد الدفع'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '١١١١١١');
    await tester.tap(find.text('تأكيد الدفع'));
    await tester.pumpAndSettle();

    expect(result.value, isTrue);
    expect(find.text('تأكيد الدفع'), findsNothing);
  });

  testWidgets('a wrong code stays on the code step; a declined payment goes back to the phone', (tester) async {
    await _pump(tester);

    await tester.enterText(find.byType(TextField), '0911234567');
    await tester.tap(find.text('إرسال رمز التحقق'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '123456');
    await tester.tap(find.text('تأكيد الدفع'));
    await tester.pumpAndSettle();
    expect(find.text('رمز التحقق غير صحيح، حاول مرة أخرى.'), findsOneWidget);
    expect(find.text('تأكيد الدفع'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '000000');
    await tester.tap(find.text('تأكيد الدفع'));
    await tester.pumpAndSettle();
    expect(find.text('لم تتم عملية الدفع، يمكنك المحاولة مرة أخرى.'), findsOneWidget);
    expect(find.text('إرسال رمز التحقق'), findsOneWidget);
  });
}
