import 'dart:math';

import '../../../../core/mock/mock_latency.dart';
import '../../../authentication/data/datasources/mock_user_store.dart';
import '../../domain/entities/leaderboard.dart';
import '../models/leaderboard_model.dart';
import 'leaderboard_remote_data_source.dart';

class LeaderboardMockDataSource implements LeaderboardRemoteDataSource {
  const LeaderboardMockDataSource(this._userStore);

  final MockUserStore _userStore;

  static const _names = [
    'Aarav Mehta',
    'Priya Singh',
    'Rohan Das',
    'Ananya Iyer',
    'Kabir Khan',
    'Sneha Patel',
    'Vikram Rao',
    'Isha Gupta',
    'Arjun Nair',
    'Meera Joshi',
    'Dev Malhotra',
    'Tara Kapoor',
    'Nikhil Verma',
    'Zoya Ali',
    'Yash Kulkarni',
  ];

  @override
  Future<LeaderboardModel> getLeaderboard(LeaderboardPeriod period) async {
    await MockLatency.simulate();
    final scale = switch (period) {
      LeaderboardPeriod.weekly => 1,
      LeaderboardPeriod.monthly => 4,
      LeaderboardPeriod.allTime => 22,
    };
    final random = Random(period.index + 7);
    var points = 1800 * scale;
    final entries = <LeaderboardEntryModel>[];
    for (var i = 0; i < _names.length; i++) {
      entries.add(
        LeaderboardEntryModel(
          rank: i + 1,
          userId: 'user_${100 + i}',
          name: _names[i],
          avatarUrl: 'https://i.pravatar.cc/150?img=${i + 20}',
          points: points,
        ),
      );
      points -= (40 + random.nextInt(120)) * scale;
    }
    final user = _userStore.currentUser ?? MockUserStore.demoUser;
    final me = LeaderboardEntryModel(
      rank: 42,
      userId: user.id,
      name: user.name,
      avatarUrl: user.avatarUrl,
      points: 310 * scale,
      isCurrentUser: true,
    );
    return LeaderboardModel(period: period, entries: entries, currentUser: me);
  }
}
