import 'package:akobrah_insurance/core/api/api_client.dart';
import 'package:akobrah_insurance/core/l10n.dart';
import 'package:akobrah_insurance/core/theme.dart';
import 'package:akobrah_insurance/features/persons/person.dart';
import 'package:akobrah_insurance/features/persons/persons_repository.dart';
import 'package:akobrah_insurance/features/travel/travel_issue_screen.dart';
import 'package:akobrah_insurance/features/travel/travel_models.dart';
import 'package:akobrah_insurance/features/travel/travel_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeTravelRepository extends TravelRepository {
  FakeTravelRepository() : super(ApiClient(Dio()));

  @override
  Future<TravelOptions> options() async => const TravelOptions(
    maxTravellers: 10,
    maxStartDaysAhead: 60,
    zones: [
      TravelZone(
        value: 'arab',
        label: 'الدول العربية',
        description: 'جميع الدول العربية',
        durations: [TravelDuration(days: 7, pricePerTraveller: 35), TravelDuration(days: 15, pricePerTraveller: 50)],
      ),
      TravelZone(
        value: 'schengen',
        label: 'أوروبا (شنغن)',
        description: 'دول منطقة شنغن',
        durations: [TravelDuration(days: 7, pricePerTraveller: 60), TravelDuration(days: 15, pricePerTraveller: 85)],
      ),
    ],
  );
}

class FakePersonsRepository extends PersonsRepository {
  FakePersonsRepository() : super(ApiClient(Dio()));

  @override
  Future<List<Person>> list() async => const [
    Person(
      id: 1,
      fullName: 'أحمد الشريف',
      relationship: Relationship.self,
      relationshipLabel: 'أنا',
      birthDate: '1988-04-12',
      age: 38,
      passportNo: 'LY1234567',
    ),
    Person(
      id: 2,
      fullName: 'سارة محمد',
      relationship: Relationship.spouse,
      relationshipLabel: 'الزوج / الزوجة',
      birthDate: '1991-09-03',
      age: 35,
    ),
  ];
}

Future<void> _pump(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(420, 1600));
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        travelRepositoryProvider.overrideWithValue(FakeTravelRepository()),
        personsRepositoryProvider.overrideWithValue(FakePersonsRepository()),
      ],
      child: MaterialApp(
        theme: AppTheme.light(),
        locale: const Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const TravelIssueScreen(initialZone: 'schengen', initialDays: 15),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

FilledButton _continueButton(WidgetTester tester) =>
    tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'متابعة'));

void main() {
  testWidgets('first person is pre-selected and the total follows zone and trip length', (tester) async {
    await _pump(tester);

    expect(find.text('مسافر واحد'), findsOneWidget);
    expect(find.text('85.00 د.ل'), findsOneWidget);
    expect(_continueButton(tester).onPressed, isNotNull);

    await tester.tap(find.text('الدول العربية'));
    await tester.pumpAndSettle();
    expect(find.text('50.00 د.ل'), findsOneWidget);

    await tester.tap(find.text('7 أيام'));
    await tester.pumpAndSettle();
    expect(find.text('35.00 د.ل'), findsOneWidget);
  });

  testWidgets('a traveller without a passport blocks the next step', (tester) async {
    await _pump(tester);

    await tester.tap(find.text('سارة محمد'));
    await tester.pumpAndSettle();

    expect(find.text('مسافران'), findsOneWidget);
    expect(find.text('170.00 د.ل'), findsOneWidget);
    expect(find.text('يرجى إضافة رقم جواز السفر لـ: سارة محمد'), findsOneWidget);
    expect(_continueButton(tester).onPressed, isNull);
  });
}
