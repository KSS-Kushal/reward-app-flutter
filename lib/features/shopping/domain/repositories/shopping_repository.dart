import '../../../../shared/models/paginated_list.dart';
import '../entities/merchant.dart';
import '../entities/product.dart';

abstract interface class ShoppingRepository {
  Future<List<MerchantCategory>> getCategories();

  Future<PaginatedList<Merchant>> getMerchants({
    String? categoryId,
    String? search,
    int page = 1,
    int pageSize = 20,
  });

  Future<Merchant> getMerchant(String id);

  /// Products of one platform, each with its affiliate "Buy now" link.
  Future<PaginatedList<Product>> getProducts({
    required String merchantId,
    String? search,
    int page = 1,
    int pageSize = 20,
  });
}
