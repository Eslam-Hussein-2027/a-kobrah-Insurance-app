import 'package:akobrah_insurance/app.dart';
import 'package:akobrah_insurance/core/api/api_client.dart';
import 'package:akobrah_insurance/core/api/api_exception.dart';
import 'package:akobrah_insurance/core/storage.dart';
import 'package:akobrah_insurance/features/auth/auth_repository.dart';
import 'package:akobrah_insurance/features/auth/models.dart';
import 'package:akobrah_insurance/features/catalog/catalog_models.dart';
import 'package:akobrah_insurance/features/catalog/catalog_repository.dart';
import 'package:akobrah_insurance/features/policies/models.dart';
import 'package:akobrah_insurance/features/policies/policies_repository.dart';
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
  FakeAuthRepository() : super(ApiClient(Dio()));

  static const password = 'secret12';
  static const code = '123456';

  final List<String> logins = [];
  final List<RegistrationInput> registrations = [];
  final List<String> resets = [];

  static const _wrongCode = ApiException(
    ApiErrorKind.validation,
    fieldErrors: {
      'code': ['رمز التحقق غير صحيح أو منتهي الصلاحية.'],
    },
  );

  @override
  Future<LoggedIn> login(String phone, String password) async {
    logins.add(phone);
    if (password != FakeAuthRepository.password) {
      throw const ApiException(
        ApiErrorKind.validation,
        fieldErrors: {
          'phone': ['رقم الهاتف أو كلمة المرور غير صحيحة.'],
        },
      );
    }
    return const LoggedIn(token: 't', user: _user);
  }

  @override
  Future<({LoggedIn? session, int resendAfter})> register(RegistrationInput input, {String? code}) async {
    registrations.add(input);
    if (code == null) return (session: null, resendAfter: 60);
    if (code != FakeAuthRepository.code) throw _wrongCode;
    return (
      session: LoggedIn(
        token: 't',
        user: AppUser(
          id: 9,
          name: '${input.firstName} ${input.lastName}',
          phone: input.phone,
          role: 'customer',
          kycCompleted: false,
          idImage: const DocumentStatus(uploaded: false),
          licenseImage: const DocumentStatus(uploaded: false),
        ),
      ),
      resendAfter: 0,
    );
  }

  @override
  Future<int> forgotPassword(String phone) async => 60;

  @override
  Future<LoggedIn> resetPassword({required String phone, required String code, required String password}) async {
    if (code != FakeAuthRepository.code) throw _wrongCode;
    resets.add('$phone:$password');
    return const LoggedIn(token: 't', user: _user);
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

class FakePoliciesRepository extends PoliciesRepository {
  FakePoliciesRepository() : super(ApiClient(Dio()));

  @override
  Future<List<Policy>> list() async => const [];
}

class FakeCatalogRepository extends CatalogRepository {
  FakeCatalogRepository() : super(ApiClient(Dio()));

  @override
  Future<List<Product>> products() async => const [
    Product(
      code: 'motor',
      name: 'التأمين الإجباري',
      title: 'التأمين الإجباري للمركبات',
      description: '',
      issuance: Issuance.instant,
      icon: 'car',
      covers: [],
      documents: [],
      fields: [],
    ),
    Product(
      code: 'marine_cargo',
      name: 'التأمين البحري',
      title: 'التأمين البحري للبضائع',
      description: '',
      issuance: Issuance.request,
      icon: 'ship',
      covers: [],
      documents: [],
      fields: [],
    ),
  ];
}

Future<FakeAuthRepository> _pumpApp(WidgetTester tester) async {
  final auth = FakeAuthRepository();
  // Tall enough for the whole sign-up form without scrolling.
  await tester.binding.setSurfaceSize(const Size(420, 1400));
  await tester.pumpWidget(
    ProviderScope(
      retry: (_, _) => null,
      overrides: [
        keyValueStoreProvider.overrideWithValue(MemoryKeyValueStore()),
        authRepositoryProvider.overrideWithValue(auth),
        vehiclesRepositoryProvider.overrideWithValue(FakeVehiclesRepository()),
        policiesRepositoryProvider.overrideWithValue(FakePoliciesRepository()),
        catalogRepositoryProvider.overrideWithValue(FakeCatalogRepository()),
      ],
      child: const AkobrahApp(),
    ),
  );
  await tester.pumpAndSettle();
  return auth;
}

Finder _field(String hint) => find.widgetWithText(TextFormField, hint);

Future<void> _signIn(
  WidgetTester tester, {
  String phone = '911234567',
  String password = FakeAuthRepository.password,
}) async {
  await tester.enterText(find.byKey(const Key('phone-field')), phone);
  await tester.enterText(find.byKey(const Key('password-field')), password);
  await tester.tap(find.text('تسجيل دخول'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('signed-out user lands on the Arabic sign-in screen (RTL)', (tester) async {
    await _pumpApp(tester);

    expect(find.text('تسجيل الدخول'), findsOneWidget);
    expect(find.text('مرحبًا بعودتك إلى التطبيق'), findsOneWidget);
    expect(find.text('+218'), findsOneWidget);
    expect(find.text('هل نسيت كلمة المرور؟'), findsOneWidget);
    expect(find.text('مستخدم جديد؟ سجّل الآن'), findsOneWidget);
    expect(Directionality.of(tester.element(find.text('تسجيل الدخول'))), TextDirection.rtl);
  });

  testWidgets('a wrong password shows the server message', (tester) async {
    await _pumpApp(tester);

    await _signIn(tester, password: 'nope');

    expect(find.text('رقم الهاتف أو كلمة المرور غير صحيحة.'), findsOneWidget);
    expect(find.text('تسجيل الدخول'), findsOneWidget);
  });

  testWidgets('existing customer: phone + password → home with products and uninsured vehicle', (tester) async {
    final auth = await _pumpApp(tester);

    await _signIn(tester, phone: '٩١١٢٣٤٥٦٧'); // after the +218 box, Arabic digits

    expect(auth.logins, ['0911234567']);
    expect(find.text('محمد العميل'), findsOneWidget);
    expect(find.text('لا توجد وثيقة سارية'), findsOneWidget);
    expect(find.text('مركبة بدون تأمين'), findsOneWidget);
    expect(find.text('Toyota Corolla 2019 · 5-123456'), findsOneWidget);
    expect(find.text('التأمين الإجباري'), findsOneWidget);
    expect(find.text('إصدار فوري'), findsOneWidget);
    expect(find.text('بطلب عرض سعر'), findsOneWidget);
  });

  testWidgets('bottom bar has four tabs and opens "My account"', (tester) async {
    await _pumpApp(tester);
    await _signIn(tester);

    // Right to left: my insurance, vehicles, home, my account. No persons tab.
    final xs = [
      'تأميناتي',
      'المركبات',
      'الرئيسية',
      'حسابي',
    ].map((label) => tester.getCenter(find.text(label).last).dx).toList();
    expect(xs, [...xs]..sort((a, b) => b.compareTo(a)));
    expect(find.text('الأشخاص'), findsNothing);

    await tester.tap(find.text('حسابي'));
    await tester.pumpAndSettle();

    expect(find.text('حسابي'), findsNWidgets(2)); // page title + tab label
    expect(find.text('محمد العميل'), findsOneWidget);
    for (final label in ['الخصوصية', 'تواصل معنا', 'عن الشركة', 'الفروع والوكلاء', 'المعلومات الشخصية', 'الإصدار']) {
      expect(find.text(label), findsOneWidget, reason: label);
    }

    await tester.tap(find.text('عن التطبيق'));
    await tester.pumpAndSettle();

    expect(find.text('إصدار الوثيقة خلال دقائق بدون زيارة المكتب'), findsOneWidget);
  });

  testWidgets('sign-up: form → SMS code → signed in', (tester) async {
    final auth = await _pumpApp(tester);

    await tester.tap(find.text('مستخدم جديد؟ سجّل الآن'));
    await tester.pumpAndSettle();
    expect(find.text('التسجيل'), findsOneWidget);
    expect(find.text('املأ النموذج لإنشاء حساب'), findsOneWidget);

    await tester.enterText(_field('الإسم'), 'سارة');
    await tester.enterText(_field('اللقب'), 'المصراتي');
    await tester.enterText(_field('أدخل رقم الهاتف'), '0921234567');
    await tester.enterText(_field('العنوان'), 'مصراتة');
    await tester.enterText(_field('أدخل كلمة المرور (6 أحرف على الأقل)'), 'abc');
    await tester.enterText(_field('تأكيد كلمة المرور'), 'abd');
    await tester.tap(find.text('تسجيل'));
    await tester.pumpAndSettle();

    expect(find.text('كلمة المرور يجب أن تكون 6 أحرف على الأقل'), findsOneWidget);
    expect(find.text('كلمتا المرور غير متطابقتين'), findsOneWidget);
    expect(auth.registrations, isEmpty);

    await tester.enterText(_field('أدخل كلمة المرور (6 أحرف على الأقل)'), 'secret12');
    await tester.enterText(_field('تأكيد كلمة المرور'), 'secret12');
    await tester.tap(find.text('تسجيل'));
    await tester.pumpAndSettle();

    expect(find.text('تأكيد رقم الهاتف'), findsOneWidget);
    expect(auth.registrations.single.toJson(), {
      'first_name': 'سارة',
      'last_name': 'المصراتي',
      'phone': '0921234567',
      'address': 'مصراتة',
      'password': 'secret12',
      'password_confirmation': 'secret12',
    });

    await tester.enterText(find.byKey(const Key('otp-field')), '000000');
    await tester.pumpAndSettle();
    expect(find.text('رمز التحقق غير صحيح أو منتهي الصلاحية.'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('otp-field')), '123456');
    await tester.pumpAndSettle();

    expect(find.text('سارة المصراتي'), findsOneWidget); // greeting on the home screen
    expect(find.text('الرئيسية'), findsOneWidget);
  });

  testWidgets('forgotten password: phone → code + new password → signed in', (tester) async {
    final auth = await _pumpApp(tester);

    await tester.tap(find.text('هل نسيت كلمة المرور؟'));
    await tester.pumpAndSettle();
    expect(find.text('استعادة كلمة المرور'), findsOneWidget);

    await tester.enterText(_field('أدخل رقم الهاتف'), '0911234567');
    await tester.tap(find.text('إرسال رمز التحقق'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('otp-field')), '123456');
    await tester.enterText(_field('أدخل كلمة المرور (6 أحرف على الأقل)'), 'new-pass1');
    await tester.enterText(_field('تأكيد كلمة المرور'), 'new-pass1');
    await tester.tap(find.text('تعيين كلمة المرور'));
    await tester.pumpAndSettle();

    expect(auth.resets, ['0911234567:new-pass1']);
    expect(find.text('محمد العميل'), findsOneWidget);
  });
}
