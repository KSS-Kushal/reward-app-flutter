import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../../domain/entities/leaderboard.dart';
import '../models/leaderboard_model.dart';

abstract interface class LeaderboardRemoteDataSource {
  Future<LeaderboardModel> getLeaderboard(LeaderboardPeriod period);
}

class LeaderboardApiDataSource implements LeaderboardRemoteDataSource {
  const LeaderboardApiDataSource(this._client);

  final ApiClient _client;

  @override
  Future<LeaderboardModel> getLeaderboard(LeaderboardPeriod period) =>
      _client.get(
        ApiEndpoints.leaderboard,
        queryParameters: {'period': period.name},
        parser: (data) => LeaderboardModel.fromJson(ApiResponse.asObject(data)),
      );
}
