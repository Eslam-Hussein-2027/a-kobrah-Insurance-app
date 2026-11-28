import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/api/api_client.dart';
import '../../shared/image_picking.dart';
import 'models.dart';

class AuthRepository {
  AuthRepository(this._api);

  final ApiClient _api;

  static String get deviceName => 'mobile-${defaultTargetPlatform.name}';

  Future<LoggedIn> login(String phone, String password) async =>
      _session(await _api.post('/auth/login', data: {'phone': phone, 'password': password, 'device_name': deviceName}));

  /// Without [code] the server may answer that it sent an SMS code (null here); with it, the account is created.
  Future<({LoggedIn? session, int resendAfter})> register(RegistrationInput input, {String? code}) async {
    final body = await _api.post('/auth/register', data: {...input.toJson(), 'device_name': deviceName, 'code': ?code});
    final data = body['data'] as Json;

    if (data['verification_required'] == true) {
      return (session: null, resendAfter: (data['resend_after'] as num).toInt());
    }
    return (session: _session(body), resendAfter: 0);
  }

  /// Always succeeds for a valid number (the server does not say whether it is registered).
  Future<int> forgotPassword(String phone) async {
    final data = (await _api.post('/auth/password/forgot', data: {'phone': phone}))['data'] as Json;
    return (data['resend_after'] as num).toInt();
  }

  Future<LoggedIn> resetPassword({required String phone, required String code, required String password}) async =>
      _session(
        await _api.post(
          '/auth/password/reset',
          data: {
            'phone': phone,
            'code': code,
            'password': password,
            'password_confirmation': password,
            'device_name': deviceName,
          },
        ),
      );

  Future<void> changePassword({required String current, required String password}) => _api.post(
    '/auth/password/change',
    data: {'current_password': current, 'password': password, 'password_confirmation': password},
  );

  Future<AppUser> me() async => AppUser.fromJson((await _api.get('/auth/me'))['data'] as Json);

  Future<AppUser> updateProfile({String? nationalId, String? address}) async => AppUser.fromJson(
    (await _api.patch('/me', data: {'national_id': ?nationalId, 'address': ?address}))['data'] as Json,
  );

  Future<void> logout() => _api.post('/auth/logout');

  Future<AppUser> uploadDocuments({XFile? idImage, XFile? licenseImage}) async {
    final form = FormData.fromMap({
      if (idImage != null) 'id_image': await toMultipart(idImage),
      if (licenseImage != null) 'license_image': await toMultipart(licenseImage),
    });
    return AppUser.fromJson((await _api.post('/me/documents', data: form))['data'] as Json);
  }

  LoggedIn _session(Json body) {
    final data = body['data'] as Json;
    return LoggedIn(token: data['token'] as String, user: AppUser.fromJson(data['user'] as Json));
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository(ref.watch(apiClientProvider)));
