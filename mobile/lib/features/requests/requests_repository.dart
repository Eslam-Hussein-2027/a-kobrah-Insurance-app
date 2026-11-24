import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/api/api_client.dart';
import '../../shared/image_picking.dart';
import '../auth/auth_controller.dart';
import 'request_models.dart';

class RequestsRepository {
  RequestsRepository(this._api);

  final ApiClient _api;

  Future<List<InsuranceRequest>> list() async =>
      (await _api.getAllPages('/requests')).map(InsuranceRequest.fromJson).toList();

  Future<InsuranceRequest> get(int id) async =>
      InsuranceRequest.fromJson((await _api.get('/requests/$id'))['data'] as Json);

  /// [answers] keyed by the product's field keys, [documents] by its document keys.
  Future<InsuranceRequest> submit({
    required String product,
    required RequestKind kind,
    required Map<String, String> answers,
    String? notes,
    Map<String, XFile> documents = const {},
  }) async {
    final form = FormData.fromMap({
      'product': product,
      'kind': kind.value,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
      for (final answer in answers.entries) 'answers[${answer.key}]': answer.value,
      for (final document in documents.entries) 'documents[${document.key}]': await toMultipart(document.value),
    });
    return InsuranceRequest.fromJson((await _api.post('/requests', data: form))['data'] as Json);
  }

  Future<InsuranceRequest> cancel(int id) async =>
      InsuranceRequest.fromJson((await _api.post('/requests/$id/cancel'))['data'] as Json);
}

final requestsRepositoryProvider = Provider<RequestsRepository>(
  (ref) => RequestsRepository(ref.watch(apiClientProvider)),
);

final requestsProvider = FutureProvider<List<InsuranceRequest>>((ref) {
  ref.watch(currentUserIdProvider);
  return ref.watch(requestsRepositoryProvider).list();
});

final requestProvider = FutureProvider.autoDispose.family<InsuranceRequest, int>(
  (ref, id) => ref.watch(requestsRepositoryProvider).get(id),
);
