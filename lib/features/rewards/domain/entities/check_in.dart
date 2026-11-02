import 'package:flutter/foundation.dart';

import 'reward_claim.dart';

enum CheckInDayState { claimed, today, upcoming, missed }

/// One day of the weekly check-in streak.
@immutable
class CheckInDay {
  const CheckInDay({
    required this.day,
    required this.coins,
    required this.state,
  });

  /// 1-based day of the streak cycle.
  final int day;
  final int coins;
  final CheckInDayState state;
}

@immutable
class CheckInStatus {
  const CheckInStatus({
    required this.currentStreak,
    required this.claimedToday,
    required this.todayReward,
    required this.days,
    this.nextCheckInAt,
    this.pendingReward,
  });

  final int currentStreak;
  final bool claimedToday;
  final int todayReward;
  final List<CheckInDay> days;

  /// When the next check-in unlocks (if already claimed today).
  final DateTime? nextCheckInAt;

  /// Today's check-in was started but its ad not watched yet. The check-in
  /// is complete only once this claim is completed.
  final PendingReward? pendingReward;
}
