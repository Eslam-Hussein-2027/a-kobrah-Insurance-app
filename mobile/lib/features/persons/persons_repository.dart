import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import '../auth/auth_controller.dart';
import 'person.dart';

class PersonsRepository {
  PersonsRepository(this._api);

  final ApiClient _api;

  Future<List<Person>> list() async =>
      ((await _api.get('/persons'))['data'] as List).cast<Json>().map(Person.fromJson).toList();

  Future<Person> create(PersonInput input) async =>
      Person.fromJson((await _api.post('/persons', data: input.toJson()))['data'] as Json);

  Future<Person> update(int id, PersonInput input) async =>
      Person.fromJson((await _api.put('/persons/$id', data: input.toJson()))['data'] as Json);

  Future<void> delete(int id) => _api.delete('/persons/$id');
}

final personsRepositoryProvider = Provider<PersonsRepository>((ref) => PersonsRepository(ref.watch(apiClientProvider)));

final personsProvider = FutureProvider<List<Person>>((ref) {
  ref.watch(currentUserIdProvider);
  return ref.watch(personsRepositoryProvider).list();
});
