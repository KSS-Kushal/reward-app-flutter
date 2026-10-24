import 'package:flutter/foundation.dart';

/// A CAPTCHA to solve.
///
/// In production the backend sends an [imageUrl] and keeps the solution
/// server-side. [previewText] exists only so the mock backend can be played
/// without an image service; a real backend must never send it.
@immutable
class CaptchaChallenge {
  const CaptchaChallenge({
    required this.id,
    required this.rewardCoins,
    required this.remainingAttempts,
    required this.totalAttempts,
    this.imageUrl,
    this.previewText,
  });

  final String id;
  final String? imageUrl;
  final String? previewText;
  final int rewardCoins;
  final int remainingAttempts;
  final int totalAttempts;

  bool get hasAttemptsLeft => remainingAttempts > 0;
}

@immutable
class CaptchaResult {
  const CaptchaResult({
    required this.isCorrect,
    required this.coinsEarned,
    required this.remainingAttempts,
    required this.message,
  });

  final bool isCorrect;
  final int coinsEarned;
  final int remainingAttempts;
  final String message;
}
