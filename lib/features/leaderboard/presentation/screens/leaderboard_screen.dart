import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_empty_view.dart';
import '../../../../core/widgets/async_value_view.dart';
import '../../../../core/widgets/gradient_page_scaffold.dart';
import '../../domain/entities/leaderboard.dart';
import '../providers/leaderboard_providers.dart';
import '../widgets/leaderboard_widgets.dart';

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  LeaderboardPeriod _period = LeaderboardPeriod.weekly;

  static String _label(LeaderboardPeriod period) => switch (period) {
    LeaderboardPeriod.weekly => 'This week',
    LeaderboardPeriod.monthly => 'This month',
    LeaderboardPeriod.allTime => 'All time',
  };

  @override
  Widget build(BuildContext context) {
    final provider = leaderboardProvider(_period);
    final leaderboard = ref.watch(provider);

    return GradientPageScaffold(
      title: 'Leader Board',
      headerBottom: Column(
        children: [
          SegmentedButton<LeaderboardPeriod>(
            segments: [
              for (final period in LeaderboardPeriod.values)
                ButtonSegment(value: period, label: Text(_label(period))),
            ],
            selected: {_period},
            showSelectedIcon: false,
            onSelectionChanged: (value) =>
                setState(() => _period = value.first),
            style: SegmentedButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              foregroundColor: AppColors.textOnDark,
              selectedBackgroundColor: AppColors.surface,
              selectedForegroundColor: AppColors.primary,
              side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
              textStyle: AppTextStyles.bodySmall,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          leaderboard.maybeWhen(
            data: (data) => LeaderboardPodium(entries: data.podium),
            error: (error, _) => const SizedBox(height: 120),
            orElse: () => const SizedBox(
              height: 150,
              child: Center(
                child: CircularProgressIndicator(color: AppColors.textOnDark),
              ),
            ),
          ),
        ],
      ),
      body: AsyncValueView(
        value: leaderboard,
        loading: const SizedBox.shrink(),
        onRetry: () => ref.invalidate(provider),
        isEmpty: (data) => data.entries.isEmpty,
        empty: const AppEmptyView(
          title: 'No leaderboard data',
          message: 'Rankings appear once people start earning.',
          icon: Icons.emoji_events_outlined,
        ),
        data: (data) => RefreshIndicator(
          onRefresh: () => ref.refresh(provider.future),
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.page),
            children: [
              if (data.currentUser case final me?) ...[
                const Text('Your rank', style: AppTextStyles.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                LeaderboardTile(entry: me),
                const SizedBox(height: AppSpacing.xl),
              ],
              for (final entry in data.rest) ...[
                LeaderboardTile(entry: entry),
                const SizedBox(height: AppSpacing.sm),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
