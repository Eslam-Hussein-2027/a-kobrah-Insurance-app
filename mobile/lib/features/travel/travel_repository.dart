import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import '../../core/locale_controller.dart';
import '../../shared/formatters.dart';
import '../policies/models.dart';
import 'travel_models.dart';

class TravelRepository {
  TravelRepository(this._api);

  final ApiClient _api;

  Future<TravelOptions> options() async => TravelOptions.fromJson((await _api.get('/travel/options'))['data'] as Json);

  /// Creates a PENDING_PAYMENT travel policy; payment continues on the policy screen.
  Future<Policy> buy(TravelSelection selection) async {
    final body = await _api.post(
      '/policies/travel',
      data: {
        'zone': selection.zone.value,
        'days': selection.duration.days,
        'start_date': isoDate(selection.startDate),
        'person_ids': [for (final person in selection.travellers) person.id],
      },
    );
    return Policy.fromJson(body['data'] as Json);
  }
}

final travelRepositoryProvider = Provider<TravelRepository>((ref) => TravelRepository(ref.watch(apiClientProvider)));

final travelOptionsProvider = FutureProvider<TravelOptions>((ref) {
  ref.watch(localeProvider);
  return ref.watch(travelRepositoryProvider).options();
});
