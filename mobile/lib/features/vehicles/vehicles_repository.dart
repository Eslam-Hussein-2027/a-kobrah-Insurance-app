import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import '../auth/auth_controller.dart';
import 'vehicle.dart';

class VehiclesRepository {
  VehiclesRepository(this._api);

  final ApiClient _api;

  Future<List<Vehicle>> list() async => (await _api.getAllPages('/vehicles')).map(Vehicle.fromJson).toList();

  Future<Vehicle> create(VehicleInput input) async =>
      Vehicle.fromJson((await _api.post('/vehicles', data: input.toJson()))['data'] as Json);

  Future<Vehicle> update(int id, VehicleInput input) async =>
      Vehicle.fromJson((await _api.patch('/vehicles/$id', data: input.toJson()))['data'] as Json);

  Future<void> delete(int id) => _api.delete('/vehicles/$id');
}

final vehiclesRepositoryProvider = Provider<VehiclesRepository>(
  (ref) => VehiclesRepository(ref.watch(apiClientProvider)),
);

final vehiclesProvider = FutureProvider<List<Vehicle>>((ref) {
  ref.watch(currentUserIdProvider);
  return ref.watch(vehiclesRepositoryProvider).list();
});
