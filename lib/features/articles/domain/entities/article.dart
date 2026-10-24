import 'package:flutter/foundation.dart';

enum ArticleRewardStatus { available, claimed, unavailable }

@immutable
class ArticleCategory {
  const ArticleCategory({required this.id, required this.name});

  final String id;
  final String name;
}

@immutable
class Article {
  const Article({
    required this.id,
    required this.title,
    required this.summary,
    required this.content,
    required this.category,
    required this.author,
    required this.publishedAt,
    required this.readTimeMinutes,
    required this.rewardCoins,
    required this.requiredReadSeconds,
    required this.rewardStatus,
    this.imageUrl,
  });

  final String id;
  final String title;
  final String summary;

  /// Body as plain paragraphs separated by blank lines.
  final String content;
  final ArticleCategory category;
  final String author;
  final DateTime publishedAt;
  final int readTimeMinutes;
  final String? imageUrl;

  /// Coins for reading this article (0 = not a reward article).
  final int rewardCoins;

  /// Minimum reading time before a reward can be claimed. The backend
  /// re-validates this; the client value only drives the progress UI.
  final int requiredReadSeconds;
  final ArticleRewardStatus rewardStatus;

  bool get hasReward => rewardCoins > 0;
  bool get canEarn =>
      hasReward && rewardStatus == ArticleRewardStatus.available;
}

/// Daily reading progress for "Read & Earn".
@immutable
class ReadingSummary {
  const ReadingSummary({
    required this.articlesReadToday,
    required this.dailyLimit,
    required this.coinsEarnedToday,
  });

  final int articlesReadToday;
  final int dailyLimit;
  final int coinsEarnedToday;

  bool get limitReached => articlesReadToday >= dailyLimit;
}

@immutable
class ArticleRewardResult {
  const ArticleRewardResult({required this.coinsEarned, required this.message});

  final int coinsEarned;
  final String message;
}
