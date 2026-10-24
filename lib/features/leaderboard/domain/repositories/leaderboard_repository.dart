import '../entities/leaderboard.dart';

abstract interface class LeaderboardRepository {
  Future<Leaderboard> getLeaderboard(LeaderboardPeriod period);
}
