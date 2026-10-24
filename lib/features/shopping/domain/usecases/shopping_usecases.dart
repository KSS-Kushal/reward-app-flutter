import '../../../../shared/models/paginated_list.dart';
import '../entities/merchant.dart';
import '../entities/product.dart';
import '../repositories/shopping_repository.dart';

class GetMerchantCategories {
  const GetMerchantCategories(this._repository);
  final ShoppingRepository _repository;

  Future<List<MerchantCategory>> call() => _repository.getCategories();
}

class SearchMerchants {
  const SearchMerchants(this._repository);
  final ShoppingRepository _repository;

  /// Blank searches are treated as "no filter".
  Future<PaginatedList<Merchant>> call({
    String? categoryId,
    String? search,
    int page = 1,
  }) {
    final query = search?.trim();
    return _repository.getMerchants(
      categoryId: categoryId,
      search: query == null || query.isEmpty ? null : query,
      page: page,
    );
  }
}

class GetMerchant {
  const GetMerchant(this._repository);
  final ShoppingRepository _repository;

  Future<Merchant> call(String id) => _repository.getMerchant(id);
}

class GetMerchantProducts {
  const GetMerchantProducts(this._repository);
  final ShoppingRepository _repository;

  /// Blank searches are treated as "no filter".
  Future<PaginatedList<Product>> call({
    required String merchantId,
    String? search,
    int page = 1,
  }) {
    final query = search?.trim();
    return _repository.getProducts(
      merchantId: merchantId,
      search: query == null || query.isEmpty ? null : query,
      page: page,
    );
  }
}
