import '../../../../shared/models/paginated_list.dart';
import '../../domain/entities/merchant.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/shopping_repository.dart';
import '../datasources/shopping_remote_data_source.dart';

class ShoppingRepositoryImpl implements ShoppingRepository {
  const ShoppingRepositoryImpl(this._remote);

  final ShoppingRemoteDataSource _remote;

  @override
  Future<List<MerchantCategory>> getCategories() => _remote.getCategories();

  @override
  Future<PaginatedList<Merchant>> getMerchants({
    String? categoryId,
    String? search,
    int page = 1,
    int pageSize = 20,
  }) => _remote.getMerchants(
    page: page,
    pageSize: pageSize,
    categoryId: categoryId,
    search: search,
  );

  @override
  Future<Merchant> getMerchant(String id) => _remote.getMerchant(id);

  @override
  Future<PaginatedList<Product>> getProducts({
    required String merchantId,
    String? search,
    int page = 1,
    int pageSize = 20,
  }) => _remote.getProducts(
    merchantId: merchantId,
    page: page,
    pageSize: pageSize,
    search: search,
  );
}
