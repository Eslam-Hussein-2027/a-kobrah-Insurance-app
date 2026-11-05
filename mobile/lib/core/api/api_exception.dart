import 'dart:convert';

import 'package:dio/dio.dart';

enum ApiErrorKind { network, unauthorized, forbidden, notFound, validation, rateLimited, server, unknown }

/// Error returned by the Laravel API envelope:
/// { "success": false, "message": "...", "errors": { "field": ["..."] } }
/// `message` is already localized by the server (Accept-Language).
class ApiException implements Exception {
  const ApiException(this.kind, {this.message, this.statusCode, this.fieldErrors = const {}});

  factory ApiException.fromDio(DioException error) {
    final response = error.response;
    if (response == null) {
      return const ApiException(ApiErrorKind.network);
    }

    final status = response.statusCode ?? 0;
    final body = _decodeBody(response.data);
    String? message;
    final fields = <String, List<String>>{};

    if (body is Map) {
      message = body['message'] as String?;
      final errors = body['errors'];
      if (errors is Map) {
        errors.forEach((key, value) {
          if (value is List) {
            fields[key.toString()] = value.map((e) => e.toString()).toList();
          }
        });
      }
    }

    final kind = switch (status) {
      401 => ApiErrorKind.unauthorized,
      403 => ApiErrorKind.forbidden,
      404 => ApiErrorKind.notFound,
      422 => ApiErrorKind.validation,
      429 => ApiErrorKind.rateLimited,
      >= 500 => ApiErrorKind.server,
      _ => ApiErrorKind.unknown,
    };

    return ApiException(kind, message: message, statusCode: status, fieldErrors: fields);
  }

  final ApiErrorKind kind;
  final String? message;
  final int? statusCode;
  final Map<String, List<String>> fieldErrors;

  String? fieldError(String field) => fieldErrors[field]?.first;

  /// Byte responses (PDF download) carry JSON errors as raw bytes.
  static Object? _decodeBody(Object? data) {
    if (data is List<int>) {
      try {
        return jsonDecode(utf8.decode(data));
      } catch (_) {
        return null;
      }
    }
    return data;
  }

  @override
  String toString() => 'ApiException($kind, $statusCode, $message)';
}
