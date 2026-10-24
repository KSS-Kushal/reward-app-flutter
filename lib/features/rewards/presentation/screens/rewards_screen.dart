import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_empty_view.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/async_value_view.dart';
import '../../../../core/widgets/coin_icon.dart';
import '../../../../core/widgets/gradient_page_scaffold.dart';
import '../../../../core/widgets/section_header.dart';
import '../../domain/entities/reward_summary.dart';
import '../providers/rewards_providers.dart';
import '../widgets/daily_rewards_grid.dart';
import '../widgets/reward_summary_card.dart';

class RewardsScreen extends ConsumerWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(rewardSummaryProvider);
    final tasks = ref.watch(dailyRewardsProvider);
    final history = ref.watch(rewardHistoryProvider);

    return GradientPageScaffold(
      title: 'Rewards',
      showBack: false,
      headerBottom: summary.when(
        data: (data) => RewardSummaryCard(summary: data),
        loading: () => const SkeletonBox(height: 124),
        error: (error, _) => AppErrorView(
          error: error,
          compact: true,
          onRetry: () => ref.invalidate(rewardSummaryProvider),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref
            ..invalidate(rewardSummaryProvider)
            ..invalidate(dailyRewardsProvider)
            ..invalidate(rewardHistoryProvider);
          await ref.read(dailyRewardsProvider.future);
        },
        child: CustomScrollView(
          slivers: [
            const _SectionTitle(
              title: 'Daily Rewards',
              icon: Icons.card_giftcard_outlined,
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
              sliver: SliverToBoxAdapter(
                child: tasks.when(
                  data: (data) => data.isEmpty
                      ? const AppEmptyView(
                          title: 'No rewards available',
                          icon: Icons.card_giftcard_outlined,
                        )
                      : DailyRewardsGrid(
                          tasks: data,
                          crossAxisCount: 2,
                          showDetails: true,
                        ),
                  loading: () => const DailyRewardsGrid(
                    tasks: null,
                    crossAxisCount: 2,
                    showDetails: true,
                  ),
                  error: (error, _) => AppErrorView(
                    error: error,
                    compact: true,
                    onRetry: () => ref.invalidate(dailyRewardsProvider),
                  ),
                ),
              ),
            ),
            const _SectionTitle(
              title: 'Reward History',
              icon: Icons.history_rounded,
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.page,
                0,
                AppSpacing.page,
                AppSizes.bottomNavClearance,
              ),
              sliver: SliverToBoxAdapter(
                child: AsyncValueView(
                  value: history,
                  compactError: true,
                  loading: const SkeletonList(itemCount: 4, itemHeight: 64),
                  onRetry: () => ref.invalidate(rewardHistoryProvider),
                  isEmpty: (items) => items.isEmpty,
                  empty: const AppEmptyView(
                    title: 'No rewards yet',
                    message: 'Complete a daily task to earn your first coins.',
                    icon: Icons.emoji_events_outlined,
                  ),
                  data: (items) => Column(
                    children: [
                      for (final item in items) ...[
                        _ActivityTile(activity: item),
                        const SizedBox(height: AppSpacing.sm),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        AppSpacing.xl,
        AppSpacing.page,
        AppSpacing.md,
      ),
      sliver: SliverToBoxAdapter(
        child: SectionHeader(title: title, icon: icon),
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.activity});

  final RewardActivity activity;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          const CoinIcon(size: 32),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  activity.description ??
                      Formatters.relative(activity.earnedAt),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          Text(
            '+${Formatters.number(activity.coins)}',
            style: AppTextStyles.titleMedium.copyWith(color: AppColors.success),
          ),
        ],
      ),
    );
  }
}
