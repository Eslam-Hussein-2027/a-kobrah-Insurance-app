import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/auth_controller.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/models.dart';
import '../features/auth/phone_code_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/auth/reset_password_screen.dart';
import '../features/auth/splash_screen.dart';
import '../features/catalog/product_screen.dart';
import '../features/home/home_screen.dart';
import '../features/account/about_app_screen.dart';
import '../features/account/change_password_screen.dart';
import '../features/account/company_pages.dart';
import '../features/account/personal_info_screen.dart';
import '../features/motor/motor_estimate_screen.dart';
import '../features/motor/motor_issue_screen.dart';
import '../features/motor/motor_review_screen.dart';
import '../features/persons/person.dart';
import '../features/persons/person_form_screen.dart';
import '../features/policies/policy_details_screen.dart';
import '../features/requests/request_details_screen.dart';
import '../features/requests/request_form_screen.dart';
import '../features/requests/request_models.dart';
import '../features/travel/travel_estimate_screen.dart';
import '../features/travel/travel_issue_screen.dart';
import '../features/travel/travel_models.dart';
import '../features/travel/travel_review_screen.dart';
import '../features/vehicles/vehicle.dart';
import '../features/vehicles/vehicle_form_screen.dart';
import '../features/verify/verify_policy_screen.dart';

const _publicPaths = {'/login', '/register', '/register/verify', '/forgot-password', '/verify'};

/// Pure redirect rule (unit-tested):
/// - auth not resolved yet (or failed on startup) → splash
/// - signed out → login (public pages allowed)
/// - signed in → never show splash/login/register
@visibleForTesting
String? authRedirect(AsyncValue<AppUser?> auth, String location) {
  if (!auth.hasValue) {
    return location == '/splash' ? null : '/splash';
  }

  final signedIn = auth.requireValue != null;
  if (!signedIn) {
    return _publicPaths.contains(location) ? null : '/login';
  }

  if (location == '/splash' || (_publicPaths.contains(location) && location != '/verify')) {
    return '/';
  }
  return null;
}

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen(authControllerProvider, (_, _) => refresh.value++);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refresh,
    redirect: (context, state) => authRedirect(ref.read(authControllerProvider), state.matchedLocation),
    routes: [
      GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (_, _) => const RegisterScreen(),
        routes: [
          GoRoute(
            path: 'verify',
            // The form travels in memory only; after a reload start the sign-up again.
            redirect: (_, state) => state.extra is RegistrationInput ? null : '/register',
            builder: (_, state) => PhoneCodeScreen(input: state.extra! as RegistrationInput),
          ),
        ],
      ),
      GoRoute(path: '/forgot-password', builder: (_, _) => const ResetPasswordScreen()),
      GoRoute(path: '/verify', builder: (_, _) => const VerifyPolicyScreen()),
      GoRoute(
        path: '/',
        builder: (_, _) => const HomeScreen(),
        routes: [
          // Catalog
          GoRoute(
            path: 'products/:code',
            builder: (_, state) => ProductScreen(code: state.pathParameters['code']!),
          ),

          // Compulsory motor insurance
          GoRoute(
            path: 'motor/issue',
            builder: (_, state) => MotorIssueScreen(vehicleId: _intQuery(state, 'vehicle')),
          ),
          GoRoute(
            path: 'motor/review/:vehicleId',
            builder: (_, state) => MotorReviewScreen(
              vehicleId: int.parse(state.pathParameters['vehicleId']!),
              startDate: DateTime.tryParse(state.uri.queryParameters['start'] ?? '') ?? DateTime.now(),
            ),
          ),
          GoRoute(path: 'motor/estimate', builder: (_, _) => const MotorEstimateScreen()),

          // Travel insurance
          GoRoute(
            path: 'travel/issue',
            builder: (_, state) => TravelIssueScreen(
              initialZone: state.uri.queryParameters['zone'],
              initialDays: _intQuery(state, 'days'),
            ),
          ),
          GoRoute(
            path: 'travel/review',
            redirect: (_, state) => state.extra is TravelSelection ? null : '/travel/issue',
            builder: (_, state) => TravelReviewScreen(selection: state.extra! as TravelSelection),
          ),
          GoRoute(path: 'travel/estimate', builder: (_, _) => const TravelEstimateScreen()),

          // Requests for staff-handled products
          GoRoute(
            path: 'requests/new',
            builder: (_, state) => RequestFormScreen(
              productCode: state.uri.queryParameters['product'] ?? '',
              kind: RequestKind.fromValue(state.uri.queryParameters['kind']),
            ),
          ),
          GoRoute(
            path: 'requests/:id',
            builder: (_, state) => RequestDetailsScreen(requestId: int.parse(state.pathParameters['id']!)),
          ),

          // Policies
          GoRoute(
            path: 'policies/:id',
            builder: (_, state) => PolicyDetailsScreen(policyId: int.parse(state.pathParameters['id']!)),
          ),

          // Vehicles and persons
          GoRoute(path: 'vehicles/new', builder: (_, _) => const VehicleFormScreen()),
          GoRoute(
            path: 'vehicles/:id/edit',
            builder: (_, state) => VehicleFormScreen(vehicle: state.extra as Vehicle?),
          ),
          GoRoute(path: 'persons/new', builder: (_, _) => const PersonFormScreen()),
          GoRoute(
            path: 'persons/:id/edit',
            builder: (_, state) => PersonFormScreen(person: state.extra as Person?),
          ),

          // More
          GoRoute(path: 'account/profile', builder: (_, _) => const PersonalInfoScreen()),
          GoRoute(path: 'account/branches', builder: (_, _) => const BranchesScreen()),
          GoRoute(path: 'account/contact', builder: (_, _) => const ContactScreen()),
          GoRoute(path: 'account/about', builder: (_, _) => const CompanyTextScreen.about()),
          GoRoute(path: 'account/privacy', builder: (_, _) => const CompanyTextScreen.privacy()),
          GoRoute(path: 'account/about-app', builder: (_, _) => const AboutAppScreen()),
          GoRoute(path: 'account/password', builder: (_, _) => const ChangePasswordScreen()),
        ],
      ),
    ],
  );
});

int? _intQuery(GoRouterState state, String key) => int.tryParse(state.uri.queryParameters[key] ?? '');
