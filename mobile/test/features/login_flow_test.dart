import 'package:akobrah_insurance/app.dart';
import 'package:akobrah_insurance/core/api/api_client.dart';
import 'package:akobrah_insurance/core/api/api_exception.dart';
import 'package:akobrah_insurance/core/storage.dart';
import 'package:akobrah_insurance/features/auth/auth_repository.dart';
import 'package:akobrah_insurance/features/auth/models.dart';
import 'package:akobrah_insurance/features/vehicles/vehicle.dart';
import 'package:akobrah_insurance/features/vehicles/vehicles_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _user = AppUser(
  id: 3,
  name: 'محمد العميل',
  phone: '0911234567',
  role: 'customer',
  kycCompleted: true,
  idImage: DocumentStatus(uploaded: true),
  licenseImage: DocumentStatus(uploaded: true),
);

class FakeAuthRepository extends AuthRepository {
  FakeAuthRepository({this.isNewUser = false}) : super(ApiClient(Dio()));

  final bool isNewUser;
  final List<String> sentTo = [];

  @override
  Future<void> sendOtp(String phone) async {
    if (phone.length != 10) {
      throw const ApiException(
        ApiErrorKind.validation,
        message: 'البيانات المدخلة غير صحيحة.',
        fieldErrors: {
          'phone': ['رقم الهاتف غير صحيح'],
        },
      );
    }
    sentTo.add(phone);
  }

  @override
  Future<OtpVerification> verifyOtp(String phone, String code) async {
    if (code != '123456') {
      throw const ApiException(
        ApiErrorKind.validation,
        fieldErrors: {
          'code': ['رمز التحقق غير صحيح أو منتهي الصلاحية.'],
        },
      );
    }
    return isNewUser ? const NeedsRegistration('reg-token') : const LoggedIn(token: 't', user: _user);
  }

  @override
  Future<AppUser> me() async => _user;
}

class FakeVehiclesRepository extends VehiclesRepository {
  FakeVehiclesRepository() : super(ApiClient(Dio()));

  @override
  Future<List<Vehicle>> list() async => const [
    Vehicle(
      id: 1,
      plateNo: '5-123456',
      vin: 'JTDBR32E720123456',
      make: 'Toyota',
      model: 'Corolla',
      year: 2019,
      engineCc: 1600,
    ),
  ];
}

Future<FakeAuthRepository> _pumpApp(WidgetTester tester, {bool isNewUser = false}) async {
  final auth = FakeAuthRepository(isNewUser: isNewUser);
  await tester.binding.setSurfaceSize(const Size(420, 900));
  await tester.pumpWidget(
    ProviderScope(
      retry: (_, _) => null,
      overrides: [
        keyValueStoreProvider.overrideWithValue(MemoryKeyValueStore()),
        authRepositoryProvider.overrideWithValue(auth),
        vehiclesRepositoryProvider.overrideWithValue(FakeVehiclesRepository()),
      ],
      child: const AkobrahApp(),
    ),
  );
  await tester.pumpAndSettle();
  return auth;
}

void main() {
  testWidgets('signed-out user lands on the Arabic login screen (RTL)', (tester) async {
    await _pumpApp(tester);

    expect(find.text('مرحبًا بك'), findsOneWidget);
    expect(find.text('إرسال رمز التحقق'), findsOneWidget);
    expect(Directionality.of(tester.element(find.text('مرحبًا بك'))), TextDirection.rtl);
  });

  testWidgets('server field errors are shown under the phone field', (tester) async {
    await _pumpApp(tester);

    await tester.enterText(find.byKey(const Key('phone-field')), '123');
    await tester.tap(find.text('إرسال رمز التحقق'));
    await tester.pumpAndSettle();

    expect(find.text('رقم الهاتف غير صحيح'), findsOneWidget);
  });

  testWidgets('existing customer: phone → OTP → home with vehicles', (tester) async {
    final auth = await _pumpApp(tester);

    await tester.enterText(find.byKey(const Key('phone-field')), '+218 91 123 4567');
    await tester.tap(find.text('إرسال رمز التحقق'));
    await tester.pumpAndSettle();

    expect(auth.sentTo, ['0911234567']);
    expect(find.text('رمز التحقق'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('otp-field')), '123456');
    await tester.pumpAndSettle();

    expect(find.text('5-123456'), findsOneWidget);
    expect(find.text('تأمين المركبة'), findsOneWidget);
  });

  testWidgets('wrong OTP shows the server message', (tester) async {
    await _pumpApp(tester);

    await tester.enterText(find.byKey(const Key('phone-field')), '0911234567');
    await tester.tap(find.text('إرسال رمز التحقق'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('otp-field')), '000000');
    await tester.pumpAndSettle();

    expect(find.text('رمز التحقق غير صحيح أو منتهي الصلاحية.'), findsOneWidget);
  });

  testWidgets('new phone number is sent to registration', (tester) async {
    await _pumpApp(tester, isNewUser: true);

    await tester.enterText(find.byKey(const Key('phone-field')), '0911234567');
    await tester.tap(find.text('إرسال رمز التحقق'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('otp-field')), '123456');
    await tester.pumpAndSettle();

    expect(find.text('إكمال التسجيل'), findsOneWidget);
    expect(find.text('الرقم الوطني'), findsOneWidget);
  });
}
