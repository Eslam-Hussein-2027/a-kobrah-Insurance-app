import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import '../../core/locale_controller.dart';
import 'catalog_models.dart';

class CatalogRepository {
  CatalogRepository(this._api);

  final ApiClient _api;

  Future<List<Product>> products() async =>
      ((await _api.get('/products'))['data'] as List).cast<Json>().map(Product.fromJson).toList();

  Future<CompanyInfo> company() async => CompanyInfo.fromJson((await _api.get('/company'))['data'] as Json);
}

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) => CatalogRepository(ref.watch(apiClientProvider)));

/// Reloaded when the app language changes (texts are localized by the server).
final productsProvider = FutureProvider<List<Product>>((ref) {
  ref.watch(localeProvider);
  return ref.watch(catalogRepositoryProvider).products();
});

final productProvider = FutureProvider.family<Product?, String>((ref, code) async {
  final products = await ref.watch(productsProvider.future);
  return products.where((p) => p.code == code).firstOrNull;
});

final companyProvider = FutureProvider<CompanyInfo>((ref) {
  ref.watch(localeProvider);
  return ref.watch(catalogRepositoryProvider).company();
});
