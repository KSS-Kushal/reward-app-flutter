import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../../../../shared/models/paginated_list.dart';
import '../models/merchant_model.dart';
import '../models/product_model.dart';

abstract interface class ShoppingRemoteDataSource {
  Future<List<MerchantCategoryModel>> getCategories();
  Future<PaginatedList<MerchantModel>> getMerchants({
    required int page,
    required int pageSize,
    String? categoryId,
    String? search,
  });
  Future<MerchantModel> getMerchant(String id);
  Future<PaginatedList<ProductModel>> getProducts({
    required String merchantId,
    required int page,
    required int pageSize,
    String? search,
  });
}

class ShoppingApiDataSource implements ShoppingRemoteDataSource {
  const ShoppingApiDataSource(this._client);

  final ApiClient _client;

  @override
  Future<List<MerchantCategoryModel>> getCategories() => _client.get(
    ApiEndpoints.merchantCategories,
    parser: (data) =>
        ApiResponse.asList(data)
            .map(MerchantCategoryModel.fromJson)
            .toList(growable: false),
  );

  @override
  Future<PaginatedList<MerchantModel>> getMerchants({
    required int page,
    required int pageSize,
    String? categoryId,
    String? search,
  }) => _client.get(
    ApiEndpoints.merchants,
    queryParameters: {
      'page': page,
      'limit': pageSize,
      'categoryId': ?categoryId,
      'q': ?search,
    },
    parser: (data) => PaginatedList.fromJson(
      ApiResponse.asObject(data),
      MerchantModel.fromJson,
    ),
  );

  @override
  Future<MerchantModel> getMerchant(String id) => _client.get(
    ApiEndpoints.merchant(id),
    parser: (data) => MerchantModel.fromJson(ApiResponse.asObject(data)),
  );

  @override
  Future<PaginatedList<ProductModel>> getProducts({
    required String merchantId,
    required int page,
    required int pageSize,
    String? search,
  }) => _client.get(
    ApiEndpoints.merchantProducts(merchantId),
    queryParameters: {'page': page, 'limit': pageSize, 'q': ?search},
    parser: (data) => PaginatedList.fromJson(
      ApiResponse.asObject(data),
      ProductModel.fromJson,
    ),
  );
}
