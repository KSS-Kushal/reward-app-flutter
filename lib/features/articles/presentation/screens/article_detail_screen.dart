import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_shadows.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/async_value_view.dart';
import '../../../../core/widgets/gradient_page_scaffold.dart';
import '../../../../shared/components/reward_result_dialog.dart';
import '../../domain/entities/article.dart';
import '../providers/article_providers.dart';

class ArticleDetailScreen extends ConsumerWidget {
  const ArticleDetailScreen({required this.articleId, super.key});

  final String articleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final article = ref.watch(articleDetailProvider(articleId));
    return GradientPageScaffold(
      title: article.value?.category.name ?? 'Article',
      body: AsyncValueView(
        value: article,
        onRetry: () => ref.invalidate(articleDetailProvider(articleId)),
        data: (data) => _ArticleBody(article: data),
      ),
    );
  }
}

class _ArticleBody extends ConsumerStatefulWidget {
  const _ArticleBody({required this.article});

  final Article article;

  @override
  ConsumerState<_ArticleBody> createState() => _ArticleBodyState();
}

class _ArticleBodyState extends ConsumerState<_ArticleBody>
    with WidgetsBindingObserver {
  late final ReadingController _reading = ref.read(
    readingProgressProvider(widget.article.id).notifier,
  );

  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.article.canEarn) _reading.start();
    // Articles shorter than the screen count as fully scrolled.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      if (_scrollController.position.maxScrollExtent <= 0) {
        _reading.updateScroll(1);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    super.dispose();
  }

  /// Reading time only counts while the app is in the foreground.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!widget.article.canEarn) return;
    if (state == AppLifecycleState.resumed) {
      _reading.start();
    } else {
      _reading.pause();
    }
  }

  bool _onScroll(ScrollNotification notification) {
    final metrics = notification.metrics;
    final progress = metrics.maxScrollExtent <= 0
        ? 1.0
        : metrics.pixels / metrics.maxScrollExtent;
    _reading.updateScroll(progress);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final article = widget.article;
    final paragraphs = article.content.split(RegExp(r'\n\s*\n'));

    return Column(
      children: [
        Expanded(
          child: NotificationListener<ScrollNotification>(
            onNotification: _onScroll,
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
              children: [
                if (article.imageUrl != null)
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: AppNetworkImage(url: article.imageUrl),
                  ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(article.title, style: AppTextStyles.headlineMedium),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        '${article.author} · ${Formatters.date(article.publishedAt)}'
                        ' · ${article.readTimeMinutes} min read',
                        style: AppTextStyles.bodySmall,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      for (final paragraph in paragraphs) ...[
                        Text(paragraph.trim(), style: AppTextStyles.bodyLarge),
                        const SizedBox(height: AppSpacing.lg),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (article.hasReward) _RewardBar(article: article),
      ],
    );
  }
}

class _RewardBar extends ConsumerWidget {
  const _RewardBar({required this.article});

  final Article article;

  Future<void> _claim(BuildContext context, WidgetRef ref) async {
    try {
      final result = await ref
          .read(readingProgressProvider(article.id).notifier)
          .claim();
      if (!context.mounted) return;
      await RewardResultDialog.show(
        context,
        title: 'Reward earned!',
        coins: result.coinsEarned,
        message: result.message,
      );
    } on Object catch (error) {
      if (context.mounted) context.showErrorSnack(error);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(readingProgressProvider(article.id));
    final claimed =
        progress.claimStatus == ClaimStatus.claimed ||
        article.rewardStatus == ArticleRewardStatus.claimed;
    final eligible = progress.isEligible(article);
    final remaining = (article.requiredReadSeconds - progress.secondsRead)
        .clamp(0, article.requiredReadSeconds);

    final String hint;
    if (claimed) {
      hint = 'Reward collected for this article';
    } else if (!article.canEarn) {
      hint = 'Reward not available';
    } else if (eligible) {
      hint = 'Your reward is ready!';
    } else if (remaining > 0) {
      hint = 'Keep reading · ${remaining}s left';
    } else {
      hint = 'Scroll to the end to unlock your reward';
    }

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        boxShadow: AppShadows.bottomNav,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            AppSpacing.md,
            AppSpacing.page,
            AppSpacing.md,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(hint, style: AppTextStyles.bodySmall),
                    const SizedBox(height: AppSpacing.sm),
                    ClipRRect(
                      borderRadius: AppRadius.pillAll,
                      child: LinearProgressIndicator(
                        value: claimed ? 1 : progress.progressFor(article),
                        minHeight: 6,
                        backgroundColor: AppColors.border,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              SizedBox(
                width: 132,
                child: AppButton(
                  label: claimed ? 'Claimed' : 'Claim +${article.rewardCoins}',
                  isLoading: progress.claimStatus == ClaimStatus.claiming,
                  onPressed: eligible && !claimed
                      ? () => _claim(context, ref)
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
