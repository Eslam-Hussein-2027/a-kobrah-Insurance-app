import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/api/api_exception.dart';
import '../../core/storage.dart';
import 'auth_repository.dart';
import 'models.dart';

/// Signed-in user (null = signed out). The router redirects based on this state.
class AuthController extends AsyncNotifier<AppUser?> {
  AuthRepository get _repository => ref.read(authRepositoryProvider);

  SessionStore get _session => ref.read(sessionStoreProvider);

  @override
  Future<AppUser?> build() async {
    final token = await _session.load();
    if (token == null) {
      return null;
    }

    try {
      return await _repository.me();
    } on ApiException catch (e) {
      if (e.kind == ApiErrorKind.unauthorized) {
        await _session.clear();
        return null;
      }
      rethrow;
    }
  }

  Future<void> sendOtp(String phone) => _repository.sendOtp(phone);

  Future<OtpVerification> verifyOtp(String phone, String code) async {
    final result = await _repository.verifyOtp(phone, code);
    if (result is LoggedIn) {
      await _signIn(result);
    }
    return result;
  }

  Future<void> register({
    required String registrationToken,
    required String name,
    required String nationalId,
    XFile? idImage,
    XFile? licenseImage,
  }) async {
    final result = await _repository.register(
      registrationToken: registrationToken,
      name: name,
      nationalId: nationalId,
      idImage: idImage,
      licenseImage: licenseImage,
    );
    await _signIn(result);
  }

  Future<void> uploadDocuments({XFile? idImage, XFile? licenseImage}) async {
    state = AsyncData(await _repository.uploadDocuments(idImage: idImage, licenseImage: licenseImage));
  }

  Future<void> refreshUser() async {
    state = AsyncData(await _repository.me());
  }

  Future<void> logout() async {
    try {
      await _repository.logout();
    } on ApiException {
      // Token may already be invalid; sign out locally regardless.
    }
    await _session.clear();
    state = const AsyncData(null);
  }

  /// Called by the API client when a signed-in request returns 401 (expired/revoked token).
  Future<void> handleUnauthorized() async {
    if (state.asData?.value == null) {
      return;
    }
    await _session.clear();
    state = const AsyncData(null);
  }

  Future<void> _signIn(LoggedIn result) async {
    await _session.save(result.token);
    state = AsyncData(result.user);
  }
}

final authControllerProvider = AsyncNotifierProvider<AuthController, AppUser?>(AuthController.new);

/// Changes when the account changes, so per-user data providers refetch.
final currentUserIdProvider = Provider<int?>(
  (ref) => ref.watch(authControllerProvider.select((state) => state.asData?.value?.id)),
);
