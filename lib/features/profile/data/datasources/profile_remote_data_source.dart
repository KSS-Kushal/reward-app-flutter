import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../../../authentication/data/models/user_model.dart';
import '../models/profile_stats_model.dart';

abstract interface class ProfileRemoteDataSource {
  Future<ProfileStatsModel> getStats();
  Future<UserModel> updateProfile({required String name, String? phone});
}

class ProfileApiDataSource implements ProfileRemoteDataSource {
  const ProfileApiDataSource(this._client);

  final ApiClient _client;

  @override
  Future<ProfileStatsModel> getStats() => _client.get(
    ApiEndpoints.profileStats,
    parser: (data) => ProfileStatsModel.fromJson(ApiResponse.asObject(data)),
  );

  @override
  Future<UserModel> updateProfile({required String name, String? phone}) =>
      _client.patch(
        ApiEndpoints.currentUser,
        body: {'name': name, 'phone': phone},
        parser: (data) => UserModel.fromJson(ApiResponse.asObject(data)),
      );
}
