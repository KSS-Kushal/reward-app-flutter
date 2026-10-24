import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/paginated_list.dart';
import '../../../../shared/models/paginated_state.dart';
import '../../../rewards/presentation/providers/rewards_providers.dart';
import '../../di/article_dependencies.dart';
import '../../domain/entities/article.dart';

final articleCategoriesProvider =
    FutureProvider.autoDispose<List<ArticleCategory>>(
      (ref) => ref.watch(getArticleCategoriesProvider).call(),
    );

final readingSummaryProvider = FutureProvider.autoDispose<ReadingSummary>(
  (ref) => ref.watch(getReadingSummaryProvider).call(),
);

final articleDetailProvider = FutureProvider.autoDispose
    .family<Article, String>(
      (ref, id) => ref.watch(getArticleProvider).call(id),
    );

/// Filter for an article list.
typedef ArticleQuery = ({String? categoryId, bool rewardableOnly});

final articlesProvider = AsyncNotifierProvider.autoDispose
    .family<ArticlesController, PaginatedState<Article>, ArticleQuery>(
      ArticlesController.new,
    );

class ArticlesController extends PaginatedController<Article> {
  ArticlesController(this.query);

  final ArticleQuery query;

  @override
  Future<PaginatedList<Article>> fetchPage(int page) => ref
      .read(getArticlesProvider)
      .call(
        categoryId: query.categoryId,
        rewardableOnly: query.rewardableOnly,
        page: page,
      );
}

// ---------------------------------------------------------------------------
// Reading session
// ---------------------------------------------------------------------------

enum ClaimStatus { idle, claiming, claimed }

@immutable
class ReadingProgress {
  const ReadingProgress({
    this.secondsRead = 0,
    this.scrollProgress = 0,
    this.claimStatus = ClaimStatus.idle,
    this.coinsEarned = 0,
  });

  final int secondsRead;

  /// 0..1, how far the user scrolled through the article.
  final double scrollProgress;
  final ClaimStatus claimStatus;
  final int coinsEarned;

  /// Reached the end and stayed long enough. The backend re-checks this.
  bool isEligible(Article article) =>
      article.canEarn &&
      secondsRead >= article.requiredReadSeconds &&
      scrollProgress >= 0.9;

  /// Combined progress used for the reward progress bar.
  double progressFor(Article article) {
    final required = article.requiredReadSeconds;
    final time = required == 0 ? 1.0 : (secondsRead / required).clamp(0.0, 1.0);
    return (time + scrollProgress.clamp(0.0, 1.0)) / 2;
  }

  ReadingProgress copyWith({
    int? secondsRead,
    double? scrollProgress,
    ClaimStatus? claimStatus,
    int? coinsEarned,
  }) => ReadingProgress(
    secondsRead: secondsRead ?? this.secondsRead,
    scrollProgress: scrollProgress ?? this.scrollProgress,
    claimStatus: claimStatus ?? this.claimStatus,
    coinsEarned: coinsEarned ?? this.coinsEarned,
  );
}

final readingProgressProvider = NotifierProvider.autoDispose
    .family<ReadingController, ReadingProgress, String>(ReadingController.new);

/// Tracks reading time and scroll depth for one article and claims the
/// reward when eligible.
class ReadingController extends Notifier<ReadingProgress> {
  ReadingController(this.articleId);

  final String articleId;
  Timer? _timer;

  @override
  ReadingProgress build() {
    ref.onDispose(() => _timer?.cancel());
    return const ReadingProgress();
  }

  /// Starts the reading clock (idempotent).
  void start() {
    _timer ??= Timer.periodic(const Duration(seconds: 1), (_) {
      state = state.copyWith(secondsRead: state.secondsRead + 1);
    });
  }

  void pause() {
    _timer?.cancel();
    _timer = null;
  }

  void updateScroll(double progress) {
    if (progress > state.scrollProgress) {
      state = state.copyWith(scrollProgress: progress.clamp(0.0, 1.0));
    }
  }

  /// Throws on failure so the screen can show the backend's reason.
  Future<ArticleRewardResult> claim() async {
    state = state.copyWith(claimStatus: ClaimStatus.claiming);
    try {
      final result = await ref
          .read(claimArticleRewardProvider)
          .call(articleId: articleId, secondsRead: state.secondsRead);
      if (ref.mounted) {
        pause();
        state = state.copyWith(
          claimStatus: ClaimStatus.claimed,
          coinsEarned: result.coinsEarned,
        );
        refreshAfterEarning(ref);
        ref
          ..invalidate(readingSummaryProvider)
          ..invalidate(articlesProvider)
          ..invalidate(articleDetailProvider(articleId));
      }
      return result;
    } on Object {
      if (ref.mounted) state = state.copyWith(claimStatus: ClaimStatus.idle);
      rethrow;
    }
  }
}
