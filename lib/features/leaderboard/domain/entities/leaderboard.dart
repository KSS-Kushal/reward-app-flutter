import 'package:flutter/foundation.dart';

enum LeaderboardPeriod { weekly, monthly, allTime }

@immutable
class LeaderboardEntry {
  const LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.name,
    required this.points,
    this.avatarUrl,
    this.isCurrentUser = false,
  });

  final int rank;
  final String userId;
  final String name;
  final String? avatarUrl;
  final int points;
  final bool isCurrentUser;
}

@immutable
class Leaderboard {
  const Leaderboard({
    required this.period,
    required this.entries,
    this.currentUser,
  });

  final LeaderboardPeriod period;

  /// Ranked entries, best first.
  final List<LeaderboardEntry> entries;

  /// The signed-in user's position, even if outside [entries].
  final LeaderboardEntry? currentUser;

  List<LeaderboardEntry> get podium => entries.take(3).toList();
  List<LeaderboardEntry> get rest => entries.skip(3).toList();
}
