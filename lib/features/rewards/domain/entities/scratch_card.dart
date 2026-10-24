import 'package:flutter/foundation.dart';

@immutable
class ScratchCardStatus {
  const ScratchCardStatus({
    required this.remainingCards,
    required this.totalCards,
    this.cardId,
  });

  /// Card ready to be scratched, or `null` when none is left today.
  final String? cardId;
  final int remainingCards;
  final int totalCards;

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
  });

  final String cardId;
  final int coinsWon;
  final int remainingCards;
  final String message;
}
