import 'dart:convert';

import 'package:akobrah_insurance/core/api/api_exception.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

DioException _error(int status, Object? data) {
  final options = RequestOptions(path: '/test');
  return DioException(
    requestOptions: options,
    response: Response<Object?>(requestOptions: options, statusCode: status, data: data),
    type: DioExceptionType.badResponse,
  );
}

void main() {
  test('validation errors keep the server message and field errors', () {
    final e = ApiException.fromDio(
      _error(422, {
        'success': false,
        'message': 'البيانات المدخلة غير صحيحة.',
        'errors': {
          'phone': ['رقم الهاتف غير صحيح'],
        },
      }),
    );

    expect(e.kind, ApiErrorKind.validation);
    expect(e.message, 'البيانات المدخلة غير صحيحة.');
    expect(e.fieldError('phone'), 'رقم الهاتف غير صحيح');
    expect(e.fieldError('name'), isNull);
  });

  test('status codes map to error kinds', () {
    expect(ApiException.fromDio(_error(401, null)).kind, ApiErrorKind.unauthorized);
    expect(ApiException.fromDio(_error(403, null)).kind, ApiErrorKind.forbidden);
    expect(ApiException.fromDio(_error(404, null)).kind, ApiErrorKind.notFound);
    expect(ApiException.fromDio(_error(429, null)).kind, ApiErrorKind.rateLimited);
    expect(ApiException.fromDio(_error(503, null)).kind, ApiErrorKind.server);
  });

  test('JSON errors returned as bytes (PDF download) are decoded', () {
    final bytes = utf8.encode(jsonEncode({'success': false, 'message': 'لا يمكن تحميل الوثيقة إلا بعد تفعيلها.'}));
    final e = ApiException.fromDio(_error(403, bytes));

    expect(e.kind, ApiErrorKind.forbidden);
    expect(e.message, 'لا يمكن تحميل الوثيقة إلا بعد تفعيلها.');
  });

  test('no response means a network error', () {
    final e = ApiException.fromDio(
      DioException(
        requestOptions: RequestOptions(path: '/x'),
        type: DioExceptionType.connectionError,
      ),
    );
    expect(e.kind, ApiErrorKind.network);
  });
}
