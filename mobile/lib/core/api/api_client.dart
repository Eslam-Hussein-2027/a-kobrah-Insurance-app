import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/auth_controller.dart';
import '../config.dart';
import '../locale_controller.dart';
import '../storage.dart';
import 'api_exception.dart';

typedef Json = Map<String, dynamic>;

/// Thin wrapper over Dio: adds auth + language headers and converts errors to [ApiException].
/// Methods return the full response envelope ({success, message, data, meta}).
class ApiClient {
  ApiClient(this._dio, {this.onUnauthorized});

  final Dio _dio;
  final void Function()? onUnauthorized;

  Future<Json> get(String path, {Map<String, dynamic>? query}) =>
      _send(() => _dio.get<dynamic>(path, queryParameters: query));

  Future<Json> post(String path, {Object? data}) => _send(() => _dio.post<dynamic>(path, data: data));

  Future<Json> patch(String path, {Object? data}) => _send(() => _dio.patch<dynamic>(path, data: data));

  Future<Json> delete(String path) => _send(() => _dio.delete<dynamic>(path));

  /// Follows Laravel pagination (meta.pagination) and returns every item.
  Future<List<Json>> getAllPages(String path, {Map<String, dynamic>? query}) async {
    final items = <Json>[];
    var page = 1;

    while (true) {
      final body = await get(path, query: {...?query, 'page': page});
      items.addAll((body['data'] as List).cast<Json>());

      final pagination = (body['meta'] as Map?)?['pagination'] as Map?;
      if (pagination == null || (pagination['current_page'] as num) >= (pagination['last_page'] as num)) {
        return items;
      }
      page++;
    }
  }

  Future<Uint8List> getBytes(String path) async {
    try {
      final response = await _dio.get<List<int>>(path, options: Options(responseType: ResponseType.bytes));
      return Uint8List.fromList(response.data ?? const []);
    } on DioException catch (e) {
      throw _map(e);
    }
  }

  Future<Json> _send(Future<Response<dynamic>> Function() request) async {
    try {
      final response = await request();
      final data = response.data;
      return data is Json ? data : <String, dynamic>{};
    } on DioException catch (e) {
      throw _map(e);
    }
  }

  ApiException _map(DioException error) {
    final exception = ApiException.fromDio(error);
    final hadToken = error.requestOptions.headers.containsKey('Authorization');
    if (exception.kind == ApiErrorKind.unauthorized && hadToken) {
      onUnauthorized?.call();
    }
    return exception;
  }
}

final apiClientProvider = Provider<ApiClient>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Accept': 'application/json'},
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = ref.read(sessionStoreProvider).token;
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        options.headers['Accept-Language'] = ref.read(localeProvider).languageCode;
        handler.next(options);
      },
    ),
  );

  return ApiClient(dio, onUnauthorized: () => ref.read(authControllerProvider.notifier).handleUnauthorized());
});
