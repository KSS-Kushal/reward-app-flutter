import 'package:flutter/foundation.dart';

import 'reward_claim.dart';

@immutable
class ScratchCardStatus {
  const ScratchCardStatus({
    required this.remainingCards,
    required this.totalCards,
    this.cardId,
    this.pendingRewards = const [],
  });

  /// Card ready to be scratched, or `null` when none is left today.
  final String? cardId;
  final int remainingCards;
  final int totalCards;

  /// Revealed prizes that still need an ad to be collected.
  final List<PendingReward> pendingRewards;

  bool get hasCard => cardId != null && remainingCards > 0;
}

/// Prize decided by the backend when the card is revealed.
@immutable
class ScratchResult {
  const ScratchResult({
    required this.cardId,
    required this.coinsWon,
    required this.remainingCards,
    required this.message,
    this.pendingReward,
  });

  final String cardId;
  final int coinsWon;
  final int remainingCards;
  final String message;

  /// Watch an ad to collect [coinsWon].
  final PendingReward? pendingReward;
}
