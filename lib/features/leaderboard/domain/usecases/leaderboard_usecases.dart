import '../entities/leaderboard.dart';
import '../repositories/leaderboard_repository.dart';

class GetLeaderboard {
  const GetLeaderboard(this._repository);
  final LeaderboardRepository _repository;

  Future<Leaderboard> call(LeaderboardPeriod period) =>
      _repository.getLeaderboard(period);
}
