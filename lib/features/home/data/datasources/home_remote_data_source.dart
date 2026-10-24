import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../models/home_models.dart';

abstract interface class HomeRemoteDataSource {
  Future<List<PromoBannerModel>> getBanners();
  Future<List<EarnOptionModel>> getEarnOptions();
}

class HomeApiDataSource implements HomeRemoteDataSource {
  const HomeApiDataSource(this._client);

  final ApiClient _client;

  @override
  Future<List<PromoBannerModel>> getBanners() => _client.get(
    ApiEndpoints.banners,
    parser: (data) =>
        ApiResponse.asList(data)
            .map(PromoBannerModel.fromJson)
            .toList(growable: false),
  );

  @override
  Future<List<EarnOptionModel>> getEarnOptions() => _client.get(
    ApiEndpoints.earnOptions,
    parser: (data) =>
        ApiResponse.asList(data)
            .map(EarnOptionModel.tryFromJson)
            .nonNulls
            .toList(growable: false),
  );
}
