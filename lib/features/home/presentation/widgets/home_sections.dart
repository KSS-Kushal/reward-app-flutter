import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/services/external_link_service.dart';
import '../../../../core/widgets/app_empty_view.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../shared/components/feature_tile_card.dart';
import '../../../quiz/presentation/providers/quiz_providers.dart';
import '../../../quiz/presentation/quiz_visuals.dart';
import '../../../rewards/presentation/providers/rewards_providers.dart';
import '../../../rewards/presentation/widgets/daily_rewards_grid.dart';
import '../earn_option_visuals.dart';
import '../home_quick_actions.dart';
import '../providers/home_providers.dart';
import 'quick_action_item.dart';

/// Rate Us / Leader Board / Contact Us / Invite.
class QuickActionsRow extends ConsumerWidget {
  const QuickActionsRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        for (final action in homeQuickActions)
          Expanded(
            child: QuickActionItem(
              label: action.label,
              icon: action.icon,
              fillColor: action.fillColor,
              ringColor: action.ringColor,
              onTap: () => switch (action.target) {
                OpenRoute(:final route) => context.push(route),
                OpenExternalUrl(:final url) =>
                  ref.read(externalLinkServiceProvider).openUrl(url),
              },
            ),
          ),
      ],
    );
  }
}

class DailyRewardsSection extends ConsumerWidget {
  const DailyRewardsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(dailyRewardsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(
          title: 'Daily Rewards',
          icon: Icons.card_giftcard_outlined,
        ),
        const SizedBox(height: AppSpacing.md),
        tasks.when(
          data: (data) => data.isEmpty
              ? const AppEmptyView(title: 'No rewards available today')
              : DailyRewardsGrid(tasks: data),
          loading: () => const DailyRewardsGrid(tasks: null),
          error: (error, _) => AppErrorView(
            error: error,
            compact: true,
            onRetry: () => ref.invalidate(dailyRewardsProvider),
          ),
        ),
      ],
    );
  }
}

class EarnMoreSection extends ConsumerWidget {
  const EarnMoreSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final options = ref.watch(earnOptionsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(
          title: 'Earn More',
          icon: Icons.star_border_rounded,
        ),
        const SizedBox(height: AppSpacing.md),
        options.when(
          data: (items) => items.isEmpty
              ? const AppEmptyView(title: 'No earning options right now')
              : _TileGrid(
                  children: [
                    for (final option in items)
                      FeatureTileCard(
                        title: option.title,
                        subtitle: option.subtitle,
                        visual: option.type.visual(imageUrl: option.imageUrl),
                        backgroundColor: option.type.surfaceColor,
                        chevronColor: option.type.accentColor,
                        chevronBackground: AppColors.surface,
                        onTap: () => context.push(option.type.route),
                      ),
                  ],
                ),
          loading: () => const _TileGridSkeleton(),
          error: (error, _) => AppErrorView(
            error: error,
            compact: true,
            onRetry: () => ref.invalidate(earnOptionsProvider),
          ),
        ),
      ],
    );
  }
}

class QuizZoneSection extends ConsumerWidget {
  const QuizZoneSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(quizCategoriesProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(
          title: 'Quiz Zone',
          icon: Icons.emoji_events_outlined,
        ),
        const SizedBox(height: AppSpacing.md),
        categories.when(
          data: (items) => items.isEmpty
              ? const AppEmptyView(
                  title: 'No quiz available',
                  icon: Icons.quiz_outlined,
                )
              : _TileGrid(
                  children: [
                    for (final quiz in items)
                      FeatureTileCard(
                        title: quiz.title,
                        subtitle: quiz.subtitle,
                        visual: quiz.type.visual(imageUrl: quiz.imageUrl),
                        chevronColor: quiz.type.accentColor,
                        badge: quiz.isCompleted ? const _DoneTag() : null,
                        onTap: () => context.push(quiz.type.route),
                      ),
                  ],
                ),
          loading: () => const _TileGridSkeleton(),
          error: (error, _) => AppErrorView(
            error: error,
            compact: true,
            onRetry: () => ref.invalidate(quizCategoriesProvider),
          ),
        ),
      ],
    );
  }
}

/// Three columns as in Figma; extra items wrap onto new rows, so the backend
/// can add options without layout changes.
class _TileGrid extends StatelessWidget {
  const _TileGrid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    return LayoutBuilder(
      builder: (context, constraints) {
        const columns = 3;
        const spacing = AppSpacing.md;
        final width =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;
        final height = 124 + (textScale - 1) * 40;
        return GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          mainAxisSpacing: spacing,
          crossAxisSpacing: spacing,
          childAspectRatio: width / height,
          children: children,
        );
      },
    );
  }
}

class _TileGridSkeleton extends StatelessWidget {
  const _TileGridSkeleton();

  @override
  Widget build(BuildContext context) {
    return const _TileGrid(
      children: [
        SkeletonBox(borderRadius: AppRadius.lgAll),
        SkeletonBox(borderRadius: AppRadius.lgAll),
        SkeletonBox(borderRadius: AppRadius.lgAll),
      ],
    );
  }
}

class _DoneTag extends StatelessWidget {
  const _DoneTag();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.12),
        borderRadius: AppRadius.pillAll,
      ),
      child: Text(
        'Done',
        style: AppTextStyles.caption.copyWith(
          color: AppColors.success,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
