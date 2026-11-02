import 'package:flutter/foundation.dart';

import 'reward_claim.dart';

@immutable
class SpinSegment {
  const SpinSegment({
    required this.id,
    required this.label,
    required this.coins,
    required this.colorHex,
  });

  final String id;
  final String label;
  final int coins;

  /// Segment colour as `#RRGGBB`, so the backend can theme the wheel.
  final String colorHex;
}

@immutable
class SpinWheelConfig {
  const SpinWheelConfig({
    required this.segments,
    required this.remainingSpins,
    required this.maxSpinsPerDay,
    this.pendingRewards = const [],
  });

  final List<SpinSegment> segments;
  final int remainingSpins;
  final int maxSpinsPerDay;

  /// Prizes won earlier that still need an ad to be collected.
  final List<PendingReward> pendingRewards;

  bool get canSpin => remainingSpins > 0 && segments.isNotEmpty;
}

/// Outcome decided by the backend; the wheel only animates to it.
@immutable
class SpinResult {
  const SpinResult({
    required this.segmentId,
    required this.coinsWon,
    required this.remainingSpins,
    this.pendingReward,
  });

  final String segmentId;
  final int coinsWon;
  final int remainingSpins;

  /// Set when [coinsWon] > 0: watch an ad to collect the coins.
  final PendingReward? pendingReward;
}
