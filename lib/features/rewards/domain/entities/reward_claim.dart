import 'package:flutter/foundation.dart';

/// Activities whose coins are credited only after a rewarded ad.
enum RewardClaimSource { checkIn, spinWheel, scratchCard }

/// Coins the backend has set aside but not credited yet.
///
/// Created by a check-in, a winning spin or a revealed scratch card. The
/// coins reach the wallet when the user watches a rewarded ad and the app
/// completes the claim (`POST /rewards/claims/{claimId}/complete`).
@immutable
class PendingReward {
  const PendingReward({
    required this.claimId,
    required this.source,
    required this.coins,
    this.expiresAt,
  });

  final String claimId;
  final RewardClaimSource source;
  final int coins;

  /// After this the claim is void (for check-in: the day ends).
  final DateTime? expiresAt;

  @override
  bool operator ==(Object other) =>
      other is PendingReward && other.claimId == claimId;

  @override
  int get hashCode => claimId.hashCode;
}

/// A completed claim: the coins are in the wallet.
@immutable
class ClaimedReward {
  const ClaimedReward({
    required this.claimId,
    required this.source,
    required this.coinsEarned,
    required this.message,
    this.newStreak,
  });

  final String claimId;
  final RewardClaimSource source;
  final int coinsEarned;
  final String message;

  /// Check-in only: the streak after this check-in.
  final int? newStreak;
}
