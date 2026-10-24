import 'package:flutter/foundation.dart';

/// Progress overview at the top of the rewards tab.
@immutable
class RewardSummary {
  const RewardSummary({
    required this.earnedToday,
    required this.totalEarned,
    required this.currentStreak,
    required this.tasksCompletedToday,
    required this.totalTasksToday,
  });

  final int earnedToday;
  final int totalEarned;
  final int currentStreak;
  final int tasksCompletedToday;
  final int totalTasksToday;

  double get dailyProgress =>
      totalTasksToday == 0 ? 0 : tasksCompletedToday / totalTasksToday;
}

/// A past reward, for the history list.
@immutable
class RewardActivity {
  const RewardActivity({
    required this.id,
    required this.title,
    required this.coins,
    required this.earnedAt,
    this.description,
  });

  final String id;
  final String title;
  final String? description;
  final int coins;
  final DateTime earnedAt;
}
