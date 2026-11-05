import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import '../auth/auth_controller.dart';
import 'models.dart';

class PoliciesRepository {
  PoliciesRepository(this._api);

  final ApiClient _api;

  Future<List<CoverageType>> coverageTypes() async =>
      ((await _api.get('/coverage-types'))['data'] as List).cast<Json>().map(CoverageType.fromJson).toList();

  Future<Quote> quote({required int vehicleId, required int coverageTypeId}) async {
    final body = await _api.post('/quotes', data: {'vehicle_id': vehicleId, 'coverage_type_id': coverageTypeId});
    return Quote.fromJson(body['data'] as Json);
  }

  Future<List<Policy>> list() async => (await _api.getAllPages('/policies')).map(Policy.fromJson).toList();

  Future<Policy> get(int id) async => Policy.fromJson((await _api.get('/policies/$id'))['data'] as Json);

  Future<Policy> create({required int vehicleId, required int coverageTypeId, DateTime? startDate}) async {
    final body = await _api.post(
      '/policies',
      data: {
        'vehicle_id': vehicleId,
        'coverage_type_id': coverageTypeId,
        if (startDate != null) 'start_date': _date(startDate),
      },
    );
    return Policy.fromJson(body['data'] as Json);
  }

  Future<Policy> cancel(int id) async => Policy.fromJson((await _api.post('/policies/$id/cancel'))['data'] as Json);

  Future<Uint8List> pdf(int id) => _api.getBytes('/policies/$id/pdf');

  Future<PolicyVerification> verify({required String policyNo, required String plateNo}) async {
    final body = await _api.get('/policies/verify', query: {'policy_no': policyNo, 'plate_no': plateNo});
    return PolicyVerification.fromJson(body['data'] as Json);
  }

  static String _date(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

final policiesRepositoryProvider = Provider<PoliciesRepository>(
  (ref) => PoliciesRepository(ref.watch(apiClientProvider)),
);

final policiesProvider = FutureProvider<List<Policy>>((ref) {
  ref.watch(currentUserIdProvider);
  return ref.watch(policiesRepositoryProvider).list();
});

final policyProvider = FutureProvider.autoDispose.family<Policy, int>(
  (ref, id) => ref.watch(policiesRepositoryProvider).get(id),
);

final coverageTypesProvider = FutureProvider<List<CoverageType>>(
  (ref) => ref.watch(policiesRepositoryProvider).coverageTypes(),
);

final quoteProvider = FutureProvider.autoDispose.family<Quote, ({int vehicleId, int coverageTypeId})>(
  (ref, args) =>
      ref.watch(policiesRepositoryProvider).quote(vehicleId: args.vehicleId, coverageTypeId: args.coverageTypeId),
);
