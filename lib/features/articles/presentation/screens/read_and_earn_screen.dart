import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/ads/ad_models.dart';
import '../../../../core/ads/widgets/banner_ad_slot.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_empty_view.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/gradient_page_scaffold.dart';
import '../../../../shared/components/paginated_list_view.dart';
import '../../domain/entities/article.dart';
import '../providers/article_providers.dart';
import '../widgets/article_card.dart';

/// "Read & Earn": reward articles with today's reading progress.
class ReadAndEarnScreen extends ConsumerWidget {
  const ReadAndEarnScreen({super.key});

  static const _query = (categoryId: null, rewardableOnly: true);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articles = ref.watch(articlesProvider(_query));
    final controller = ref.read(articlesProvider(_query).notifier);
    final summary = ref.watch(readingSummaryProvider);

    return GradientPageScaffold(
      title: 'Read & Earn',
      bottomBar: const BannerAdSlot(placement: AdPlacement.article),
      body: PaginatedListView(
        value: articles,
        onRefresh: () async {
          ref.invalidate(readingSummaryProvider);
          await controller.refresh();
        },
        onLoadMore: controller.loadMore,
        header: summary.when(
          data: (data) => _SummaryCard(summary: data),
          loading: () => const SkeletonBox(height: 96),
          error: (_, _) => const SizedBox.shrink(),
        ),
        empty: const AppEmptyView(
          title: 'No reward articles right now',
          message: 'New articles are added every day.',
          icon: Icons.menu_book_outlined,
        ),
        itemBuilder: (context, article) => ArticleCard(
          article: article,
          onTap: () => context.push(AppRoutes.articleDetail(article.id)),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.summary});

  final ReadingSummary summary;

  @override
  Widget build(BuildContext context) {
    final progress = summary.dailyLimit == 0
        ? 0.0
        : summary.articlesReadToday / summary.dailyLimit;
    return AppCard(
      color: AppColors.readEarnSurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_stories_rounded,
                color: AppColors.primaryDark,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  summary.limitReached
                      ? "You've hit today's reading limit"
                      : 'Read to the end to earn coins',
                  style: AppTextStyles.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: AppRadius.pillAll,
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              color: AppColors.primaryDark,
              backgroundColor: Colors.white.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${summary.articlesReadToday} of ${summary.dailyLimit} articles '
            'today · ${summary.coinsEarnedToday} coins earned',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
