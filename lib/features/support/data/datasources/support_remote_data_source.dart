import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../models/support_info_model.dart';

abstract interface class SupportRemoteDataSource {
  Future<SupportInfoModel> getSupportInfo();
}

class SupportApiDataSource implements SupportRemoteDataSource {
  const SupportApiDataSource(this._client);

  final ApiClient _client;

  @override
  Future<SupportInfoModel> getSupportInfo() => _client.get(
    ApiEndpoints.support,
    parser: (data) => SupportInfoModel.fromJson(ApiResponse.asObject(data)),
  );
}
