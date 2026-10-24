import 'package:flutter/foundation.dart';

/// Achievements shown under the profile header.
@immutable
class ProfileStats {
  const ProfileStats({
    required this.totalEarned,
    required this.currentStreak,
    required this.rank,
    required this.referrals,
  });

  final int totalEarned;
  final int currentStreak;
  final int rank;
  final int referrals;
}
