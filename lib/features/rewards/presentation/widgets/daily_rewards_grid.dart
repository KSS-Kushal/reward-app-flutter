import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_dimensions.dart';
import '../../domain/entities/reward_task.dart';
import '../reward_visuals.dart';
import 'reward_card.dart';

/// Grid of [RewardCard]s. Used by the home "Daily Rewards" row (4 columns)
/// and by the rewards tab (2 columns with subtitles).
class DailyRewardsGrid extends StatelessWidget {
  const DailyRewardsGrid({
    required this.tasks,
    this.crossAxisCount = 4,
    this.showDetails = false,
    super.key,
  });

  /// Number of skeleton cards shown while loading.
  static const placeholderCount = 4;

  final List<RewardTask>? tasks;
  final int crossAxisCount;
  final bool showDetails;

  bool get _isLoading => tasks == null;

  @override
  Widget build(BuildContext context) {
    final items = tasks;
    final count = items?.length ?? placeholderCount;
    return LayoutBuilder(
      builder: (context, constraints) {
        // Keep cards tall enough for two-line titles at any text scale.
        final textScale = MediaQuery.textScalerOf(context).scale(1);
        final baseHeight = showDetails ? 178.0 : 150.0;
        final spacing = crossAxisCount == 4 ? AppSpacing.sm : AppSpacing.md;
        final width =
            (constraints.maxWidth - spacing * (crossAxisCount - 1)) /
            crossAxisCount;
        final height = baseHeight + (textScale - 1) * 40;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: count,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: spacing,
            crossAxisSpacing: spacing,
            childAspectRatio: width / height,
          ),
          itemBuilder: (context, index) {
            if (items == null) return _placeholder(index);
            final task = items[index];
            return RewardCard(
              title: task.title,
              subtitle: showDetails ? task.subtitle : null,
              actionLabel: task.actionLabel,
              visual: task.type.visual(imageUrl: task.imageUrl),
              surfaceColor: task.type.surfaceColor,
              actionColor: task.type.actionColor,
              status: task.status,
              rewardCoins: task.rewardCoins,
              onPressed: () => context.push(task.type.route),
            );
          },
        );
      },
    );
  }

  Widget _placeholder(int index) {
    final type = RewardTaskType.values[index % RewardTaskType.values.length];
    return RewardCard(
      title: '',
      actionLabel: '',
      visual: type.visual(),
      surfaceColor: type.surfaceColor,
      actionColor: type.actionColor,
      isLoading: _isLoading,
    );
  }
}
