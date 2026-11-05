import 'package:akobrah_insurance/core/router.dart';
import 'package:akobrah_insurance/features/auth/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _user = AppUser(
  id: 1,
  name: 'محمد',
  phone: '0911234567',
  role: 'customer',
  kycCompleted: true,
  idImage: DocumentStatus(uploaded: true),
  licenseImage: DocumentStatus(uploaded: true),
);

void main() {
  test('while auth is loading, everything goes to the splash screen', () {
    const loading = AsyncLoading<AppUser?>();
    expect(authRedirect(loading, '/'), '/splash');
    expect(authRedirect(loading, '/splash'), isNull);
  });

  test('signed-out users can only see public pages', () {
    const signedOut = AsyncData<AppUser?>(null);
    expect(authRedirect(signedOut, '/splash'), '/login');
    expect(authRedirect(signedOut, '/'), '/login');
    expect(authRedirect(signedOut, '/policies/5'), '/login');
    expect(authRedirect(signedOut, '/login'), isNull);
    expect(authRedirect(signedOut, '/login/otp'), isNull);
    expect(authRedirect(signedOut, '/register'), isNull);
    expect(authRedirect(signedOut, '/verify'), isNull);
  });

  test('signed-in users skip login screens but may verify policies', () {
    const signedIn = AsyncData<AppUser?>(_user);
    expect(authRedirect(signedIn, '/splash'), '/');
    expect(authRedirect(signedIn, '/login'), '/');
    expect(authRedirect(signedIn, '/login/otp'), '/');
    expect(authRedirect(signedIn, '/register'), '/');
    expect(authRedirect(signedIn, '/verify'), isNull);
    expect(authRedirect(signedIn, '/policies/5'), isNull);
  });
}
