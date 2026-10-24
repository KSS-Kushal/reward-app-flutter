import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/core_providers.dart';
import '../data/datasources/shopping_mock_data_source.dart';
import '../data/datasources/shopping_remote_data_source.dart';
import '../data/repositories/shopping_repository_impl.dart';
import '../domain/repositories/shopping_repository.dart';
import '../domain/usecases/shopping_usecases.dart';

final shoppingRemoteDataSourceProvider = Provider<ShoppingRemoteDataSource>((
  ref,
) {
  if (ref.watch(useMockApiProvider)) return const ShoppingMockDataSource();
  return ShoppingApiDataSource(ref.watch(apiClientProvider));
});

final shoppingRepositoryProvider = Provider<ShoppingRepository>(
  (ref) => ShoppingRepositoryImpl(ref.watch(shoppingRemoteDataSourceProvider)),
);

final getMerchantCategoriesProvider = Provider(
  (ref) => GetMerchantCategories(ref.watch(shoppingRepositoryProvider)),
);
final searchMerchantsProvider = Provider(
  (ref) => SearchMerchants(ref.watch(shoppingRepositoryProvider)),
);
final getMerchantProvider = Provider(
  (ref) => GetMerchant(ref.watch(shoppingRepositoryProvider)),
);
final getMerchantProductsProvider = Provider(
  (ref) => GetMerchantProducts(ref.watch(shoppingRepositoryProvider)),
);
