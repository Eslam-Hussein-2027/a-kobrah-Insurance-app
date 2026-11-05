import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/auth_controller.dart';
import '../features/auth/models.dart';
import '../features/auth/otp_screen.dart';
import '../features/auth/phone_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/auth/splash_screen.dart';
import '../features/home/home_screen.dart';
import '../features/policies/insure_screen.dart';
import '../features/policies/policy_details_screen.dart';
import '../features/vehicles/vehicle.dart';
import '../features/vehicles/vehicle_form_screen.dart';
import '../features/verify/verify_policy_screen.dart';

const _publicPaths = {'/login', '/login/otp', '/register', '/verify'};

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
      GoRoute(
        path: '/login',
        builder: (_, _) => const PhoneScreen(),
        routes: [
          GoRoute(
            path: 'otp',
            builder: (_, state) => OtpScreen(phone: state.uri.queryParameters['phone'] ?? ''),
          ),
        ],
      ),
      GoRoute(
        path: '/register',
        builder: (_, state) => RegisterScreen(registrationToken: state.extra as String? ?? ''),
      ),
      GoRoute(path: '/verify', builder: (_, _) => const VerifyPolicyScreen()),
      GoRoute(
        path: '/',
        builder: (_, _) => const HomeScreen(),
        routes: [
          GoRoute(path: 'vehicles/new', builder: (_, _) => const VehicleFormScreen()),
          GoRoute(
            path: 'vehicles/:id/edit',
            builder: (_, state) => VehicleFormScreen(vehicle: state.extra as Vehicle?),
          ),
          GoRoute(
            path: 'insure/:vehicleId',
            builder: (_, state) => InsureScreen(vehicleId: int.parse(state.pathParameters['vehicleId']!)),
          ),
          GoRoute(
            path: 'policies/:id',
            builder: (_, state) => PolicyDetailsScreen(policyId: int.parse(state.pathParameters['id']!)),
          ),
        ],
      ),
    ],
  );
});
