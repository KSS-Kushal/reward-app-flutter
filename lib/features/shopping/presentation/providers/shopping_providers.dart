import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/paginated_list.dart';
import '../../../../shared/models/paginated_state.dart';
import '../../di/shopping_dependencies.dart';
import '../../domain/entities/merchant.dart';
import '../../domain/entities/product.dart';

final merchantCategoriesProvider =
    FutureProvider.autoDispose<List<MerchantCategory>>(
      (ref) => ref.watch(getMerchantCategoriesProvider).call(),
    );

final merchantDetailProvider = FutureProvider.autoDispose
    .family<Merchant, String>(
      (ref, id) => ref.watch(getMerchantProvider).call(id),
    );

typedef MerchantQuery = ({String? categoryId, String search});

final merchantsProvider = AsyncNotifierProvider.autoDispose
    .family<MerchantsController, PaginatedState<Merchant>, MerchantQuery>(
      MerchantsController.new,
    );

class MerchantsController extends PaginatedController<Merchant> {
  MerchantsController(this.query);

  final MerchantQuery query;

  @override
  Future<PaginatedList<Merchant>> fetchPage(int page) => ref
      .read(searchMerchantsProvider)
      .call(categoryId: query.categoryId, search: query.search, page: page);
}

typedef ProductQuery = ({String merchantId, String search});

/// Products of one platform, filtered by [ProductQuery.search].
final merchantProductsProvider = AsyncNotifierProvider.autoDispose
    .family<ProductsController, PaginatedState<Product>, ProductQuery>(
      ProductsController.new,
    );

class ProductsController extends PaginatedController<Product> {
  ProductsController(this.query);

  final ProductQuery query;

  @override
  Future<PaginatedList<Product>> fetchPage(int page) => ref
      .read(getMerchantProductsProvider)
      .call(merchantId: query.merchantId, search: query.search, page: page);
}
