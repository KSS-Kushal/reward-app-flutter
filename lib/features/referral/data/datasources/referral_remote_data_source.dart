import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../models/referral_model.dart';

abstract interface class ReferralRemoteDataSource {
  Future<ReferralInfoModel> getReferralInfo();
}

class ReferralApiDataSource implements ReferralRemoteDataSource {
  const ReferralApiDataSource(this._client);

  final ApiClient _client;

  @override
  Future<ReferralInfoModel> getReferralInfo() => _client.get(
    ApiEndpoints.referral,
    parser: (data) => ReferralInfoModel.fromJson(ApiResponse.asObject(data)),
  );
}
