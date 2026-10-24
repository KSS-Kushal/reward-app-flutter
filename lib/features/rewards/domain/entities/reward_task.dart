import 'package:flutter/foundation.dart';

enum RewardTaskType { dailyCheckIn, spinWheel, scratchCard, captcha }

enum RewardTaskStatus { available, completed, locked }

/// A daily reward activity shown on the home screen and rewards tab.
@immutable
class RewardTask {
  const RewardTask({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.rewardCoins,
    required this.status,
    this.remainingAttempts,
    this.totalAttempts,
    this.imageUrl,
  });

  final String id;
  final RewardTaskType type;
  final String title;
  final String subtitle;

  /// Call to action ("Check-in", "Spin", "Play", "Start").
  final String actionLabel;

  /// Maximum coins this activity can award.
  final int rewardCoins;
  final RewardTaskStatus status;
  final int? remainingAttempts;
  final int? totalAttempts;

  /// Optional backend-provided illustration.
  final String? imageUrl;

  bool get isAvailable => status == RewardTaskStatus.available;
  bool get isCompleted => status == RewardTaskStatus.completed;
  bool get isLocked => status == RewardTaskStatus.locked;
}
