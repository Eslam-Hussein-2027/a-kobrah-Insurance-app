import 'package:akobrah_insurance/core/api/api_client.dart';
import 'package:akobrah_insurance/core/l10n.dart';
import 'package:akobrah_insurance/core/storage.dart';
import 'package:akobrah_insurance/core/theme.dart';
import 'package:akobrah_insurance/features/vehicles/vehicle.dart';
import 'package:akobrah_insurance/features/vehicles/vehicle_form_screen.dart';
import 'package:akobrah_insurance/features/vehicles/vehicles_repository.dart';
import 'package:akobrah_insurance/shared/widgets.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class FakeVehiclesRepository extends VehiclesRepository {
  FakeVehiclesRepository() : super(ApiClient(Dio()));

  final List<VehicleInput> created = [];

  @override
  Future<VehicleOptions> options() async => const VehicleOptions(
    makes: [(value: 'Toyota', label: 'تويوتا'), (value: 'Kia', label: 'كيا')],
    colors: [(value: 'white', label: 'أبيض'), (value: 'black', label: 'أسود')],
    countries: [(value: 'japan', label: 'اليابان'), (value: 'south_korea', label: 'كوريا الجنوبية')],
    licensePurposes: [(value: 'private', label: 'خاصة'), (value: 'taxi', label: 'أجرة (تاكسي)')],
    licensingAuthorities: [(value: 'tripoli', label: 'مرور طرابلس'), (value: 'benghazi', label: 'مرور بنغازي')],
    minYear: 2015,
    maxYear: 2027,
    minSeats: 1,
    maxSeats: 60,
  );

  @override
  Future<List<Vehicle>> list() async => const [];

  @override
  Future<Vehicle> create(VehicleInput input) async {
    created.add(input);
    return Vehicle(
      id: 1,
      plateNo: input.plateNo,
      vin: input.vin,
      make: input.make,
      model: input.model,
      year: input.year,
      engineCc: input.engineCc,
      detailsComplete: true,
    );
  }
}

Future<FakeVehiclesRepository> _pump(WidgetTester tester) async {
  final repository = FakeVehiclesRepository();
  // Tall enough for the whole form, so every field is built without scrolling.
  await tester.binding.setSurfaceSize(const Size(420, 2600));
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, _) => Scaffold(
          body: Center(
            child: FilledButton(onPressed: () => context.push('/new'), child: const Text('open')),
          ),
        ),
      ),
      GoRoute(path: '/new', builder: (_, _) => const VehicleFormScreen()),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        keyValueStoreProvider.overrideWithValue(MemoryKeyValueStore()),
        vehiclesRepositoryProvider.overrideWithValue(repository),
      ],
      child: MaterialApp.router(
        theme: AppTheme.light(),
        locale: const Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  return repository;
}

Future<void> _choose(WidgetTester tester, String field, String option) async {
  await tester.tap(find.byKey(ValueKey(field)));
  await tester.pumpAndSettle();
  final list = find.descendant(of: find.byType(BottomSheet), matching: find.byType(ListView));
  final item = find.descendant(of: list, matching: find.text(option));
  await tester.scrollUntilVisible(
    item,
    120,
    scrollable: find.descendant(of: list, matching: find.byType(Scrollable)),
  );
  await tester.tap(item);
  await tester.pumpAndSettle();
}

Future<void> _type(WidgetTester tester, String hint, String text) async {
  await tester.enterText(find.widgetWithText(TextFormField, hint), text);
}

void main() {
  testWidgets('the form has the owner and vehicle sections and requires every field', (tester) async {
    final repository = await _pump(tester);

    expect(find.text('تنبيه'), findsOneWidget);
    expect(find.text('يرجى التأكد من صحة البيانات قبل إرسالها.'), findsOneWidget);
    expect(find.text('بيانات المؤمن'), findsOneWidget);
    expect(find.text('بيانات المركبة'), findsOneWidget);
    expect(find.text('انقر لاختيار سنة الصنع'), findsOneWidget);

    await tester.tap(find.byType(PrimaryButton));
    await tester.pumpAndSettle();

    // owner name, address, make, model, colour, engine, country, year, purpose, seats, plate, vin, authority
    expect(find.text('هذا الحقل مطلوب'), findsNWidgets(13));
    expect(repository.created, isEmpty);
  });

  testWidgets('a filled form sends codes and western digits; unlisted brands can be typed', (tester) async {
    final repository = await _pump(tester);

    await _type(tester, 'اسم مالك السيارة', 'أحمد الشريف');
    await _type(tester, 'عنوان مالك السيارة', 'بنغازي - الفويهات');

    // Brand not in the list: typed in the search box and used as is.
    await tester.tap(find.byKey(const ValueKey('make')));
    await tester.pumpAndSettle();
    await tester.enterText(find.descendant(of: find.byType(BottomSheet), matching: find.byType(TextField)), 'Lada');
    await tester.pumpAndSettle();
    await tester.tap(find.text('استخدام «Lada»'));
    await tester.pumpAndSettle();
    expect(find.text('Lada'), findsOneWidget);

    await _type(tester, 'Corolla', 'Niva');
    await _choose(tester, 'color', 'أبيض');
    await _type(tester, '1600', '١٦٠٠');
    await _choose(tester, 'country_of_origin', 'اليابان');
    await _choose(tester, 'year', '2019');
    await _choose(tester, 'license_purpose', 'خاصة');
    await _type(tester, '5', '٧٠');
    await _type(tester, 'مثال: 5-123456', '5-123456');
    await _type(tester, '17 حرفًا ورقمًا', 'jtdbr32e720123456');
    await _choose(tester, 'licensing_authority', 'مرور بنغازي');

    await tester.tap(find.byType(PrimaryButton));
    await tester.pumpAndSettle();
    expect(find.text('أدخل رقمًا من 1 إلى 60'), findsOneWidget);
    expect(repository.created, isEmpty);

    await _type(tester, '5', '5');
    await tester.tap(find.byType(PrimaryButton));
    await tester.pumpAndSettle();

    expect(repository.created.single.toJson(), {
      'owner_name': 'أحمد الشريف',
      'owner_address': 'بنغازي - الفويهات',
      'plate_no': '5-123456',
      'vin': 'JTDBR32E720123456',
      'make': 'Lada',
      'model': 'Niva',
      'year': 2019,
      'engine_cc': 1600,
      'color': 'white',
      'country_of_origin': 'japan',
      'license_purpose': 'private',
      'seats': 5,
      'licensing_authority': 'benghazi',
    });
    expect(find.text('open'), findsOneWidget); // back on the previous screen
  });
}
