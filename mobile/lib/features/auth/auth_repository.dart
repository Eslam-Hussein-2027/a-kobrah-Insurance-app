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

  Future<void> sendOtp(String phone) => _api.post('/auth/otp/send', data: {'phone': phone});

  Future<OtpVerification> verifyOtp(String phone, String code) async {
    final body = await _api.post('/auth/otp/verify', data: {'phone': phone, 'code': code, 'device_name': deviceName});
    final data = body['data'] as Json;

    if (data['is_new_user'] == true) {
      return NeedsRegistration(data['registration_token'] as String);
    }
    return LoggedIn(token: data['token'] as String, user: AppUser.fromJson(data['user'] as Json));
  }

  Future<LoggedIn> register({
    required String registrationToken,
    required String name,
    required String nationalId,
    XFile? idImage,
    XFile? licenseImage,
  }) async {
    final form = FormData.fromMap({
      'registration_token': registrationToken,
      'name': name,
      'national_id': nationalId,
      'device_name': deviceName,
      if (idImage != null) 'id_image': await toMultipart(idImage),
      if (licenseImage != null) 'license_image': await toMultipart(licenseImage),
    });

    final data = (await _api.post('/auth/register', data: form))['data'] as Json;
    return LoggedIn(token: data['token'] as String, user: AppUser.fromJson(data['user'] as Json));
  }

  Future<AppUser> me() async => AppUser.fromJson((await _api.get('/auth/me'))['data'] as Json);

  Future<void> logout() => _api.post('/auth/logout');

  Future<AppUser> uploadDocuments({XFile? idImage, XFile? licenseImage}) async {
    final form = FormData.fromMap({
      if (idImage != null) 'id_image': await toMultipart(idImage),
      if (licenseImage != null) 'license_image': await toMultipart(licenseImage),
    });
    return AppUser.fromJson((await _api.post('/me/documents', data: form))['data'] as Json);
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository(ref.watch(apiClientProvider)));
