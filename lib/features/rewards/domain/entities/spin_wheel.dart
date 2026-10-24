import 'package:flutter/foundation.dart';

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
  });

  final List<SpinSegment> segments;
  final int remainingSpins;
  final int maxSpinsPerDay;

  bool get canSpin => remainingSpins > 0 && segments.isNotEmpty;
}

/// Outcome decided by the backend; the wheel only animates to it.
@immutable
class SpinResult {
  const SpinResult({
    required this.segmentId,
    required this.coinsWon,
    required this.remainingSpins,
  });

  final String segmentId;
  final int coinsWon;
  final int remainingSpins;
}
