import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import '../auth/auth_controller.dart';
import '../../shared/formatters.dart';
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

  /// "Know the price" for a vehicle that is not registered yet (compulsory coverage).
  Future<Quote> estimate({required int manufactureYear, required int engineCc}) async {
    final body = await _api.post(
      '/quotes/estimate',
      data: {'manufacture_year': manufactureYear, 'engine_cc': engineCc},
    );
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
        if (startDate != null) 'start_date': isoDate(startDate),
      },
    );
    return Policy.fromJson(body['data'] as Json);
  }

  Future<Policy> cancel(int id) async => Policy.fromJson((await _api.post('/policies/$id/cancel'))['data'] as Json);

  Future<Uint8List> pdf(int id) => _api.getBytes('/policies/$id/pdf');

  /// Starts an online payment; returns the provider checkout URL to open.
  Future<PaymentOptions> paymentOptions() async =>
      PaymentOptions.fromJson((await _api.get('/payments/options'))['data'] as Json);

  /// Starts an online payment. OTP flow: [phone] and [payMethod] are required and the customer gets a code.
  Future<OnlinePayment> payOnline(int policyId, {String? phone, String? payMethod}) async {
    final body = await _api.post('/policies/$policyId/pay-online', data: {'phone': ?phone, 'pay_method': ?payMethod});
    return OnlinePayment.fromJson(body['data'] as Json);
  }

  /// OTP flow: the code the customer received by SMS.
  Future<({OnlinePayment payment, String? message})> confirmPayment(int paymentId, String otp) async {
    final body = await _api.post('/payments/$paymentId/confirm', data: {'otp': otp});
    return (payment: OnlinePayment.fromJson(body['data'] as Json), message: body['message'] as String?);
  }

  /// Current status (the server re-checks with the payment provider while pending).
  Future<OnlinePayment> payment(int paymentId) async =>
      OnlinePayment.fromJson((await _api.get('/payments/$paymentId'))['data'] as Json);

  Future<PolicyVerification> verify({required String policyNo, required String plateNo}) async {
    final body = await _api.get('/policies/verify', query: {'policy_no': policyNo, 'plate_no': plateNo});
    return PolicyVerification.fromJson(body['data'] as Json);
  }
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
