import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/async_value_view.dart';
import '../../../../core/widgets/coin_icon.dart';
import '../../../../core/widgets/gradient_page_scaffold.dart';
import '../../../../shared/components/reward_result_dialog.dart';
import '../../domain/entities/check_in.dart';
import '../providers/reward_game_controllers.dart';

class DailyCheckInScreen extends ConsumerStatefulWidget {
  const DailyCheckInScreen({super.key});

  @override
  ConsumerState<DailyCheckInScreen> createState() => _DailyCheckInScreenState();
}

class _DailyCheckInScreenState extends ConsumerState<DailyCheckInScreen> {
  bool _claiming = false;

  Future<void> _claim() async {
    setState(() => _claiming = true);
    try {
      final result = await ref.read(checkInControllerProvider.notifier).claim();
      if (!mounted) return;
      await RewardResultDialog.show(
        context,
        title: 'Check-in complete!',
        coins: result.coinsEarned,
        message: "You're on a ${result.newStreak}-day streak. Keep it going!",
      );
    } on Object catch (error) {
      if (mounted) context.showErrorSnack(error);
    } finally {
      if (mounted) setState(() => _claiming = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = ref.watch(checkInControllerProvider);
    return GradientPageScaffold(
      title: 'Daily Check-in',
      body: AsyncValueView(
        value: status,
        onRetry: () => ref.invalidate(checkInControllerProvider),
        data: (data) => ListView(
          padding: const EdgeInsets.all(AppSpacing.page),
          children: [
            _StreakCard(status: data),
            const SizedBox(height: AppSpacing.xxl),
            const Text('This week', style: AppTextStyles.titleMedium),
            const SizedBox(height: AppSpacing.md),
            _DaysGrid(days: data.days),
            const SizedBox(height: AppSpacing.xxl),
            AppButton(
              label: data.claimedToday
                  ? 'Come back tomorrow'
                  : 'Claim ${data.todayReward} coins',
              icon: data.claimedToday
                  ? const Icon(Icons.check_circle_rounded)
                  : null,
              isLoading: _claiming,
              onPressed: data.claimedToday ? null : _claim,
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text(
              'Check in every day to grow your streak. Missing a day resets '
              'it, and day 7 pays the biggest reward.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  const _StreakCard({required this.status});

  final CheckInStatus status;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: AppColors.checkInSurface,
      child: Row(
        children: [
          const Icon(
            Icons.local_fire_department_rounded,
            color: AppColors.scratchAction,
            size: 48,
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${status.currentStreak}-day streak',
                  style: AppTextStyles.titleLarge,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  status.claimedToday
                      ? "Today's reward collected"
                      : "Today's reward is waiting",
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          CoinAmount(amount: status.todayReward, iconSize: 22),
        ],
      ),
    );
  }
}

class _DaysGrid extends StatelessWidget {
  const _DaysGrid({required this.days});

  final List<CheckInDay> days;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: days.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: 0.8,
      ),
      itemBuilder: (context, index) => _DayTile(day: days[index]),
    );
  }
}

class _DayTile extends StatelessWidget {
  const _DayTile({required this.day});

  final CheckInDay day;

  @override
  Widget build(BuildContext context) {
    final (background, border, foreground) = switch (day.state) {
      CheckInDayState.claimed => (
        AppColors.checkInAction,
        AppColors.checkInAction,
        Colors.white,
      ),
      CheckInDayState.today => (
        AppColors.surface,
        AppColors.checkInAction,
        AppColors.textPrimary,
      ),
      CheckInDayState.missed => (
        AppColors.surfaceMuted,
        AppColors.border,
        AppColors.textTertiary,
      ),
      CheckInDayState.upcoming => (
        AppColors.surface,
        AppColors.border,
        AppColors.textPrimary,
      ),
    };

    return Semantics(
      label: 'Day ${day.day}, ${day.coins} coins, ${day.state.name}',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: background,
          borderRadius: AppRadius.mdAll,
          border: Border.all(
            color: border,
            width: day.state == CheckInDayState.today ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Day ${day.day}',
              style: AppTextStyles.bodySmall.copyWith(color: foreground),
            ),
            const SizedBox(height: AppSpacing.xs),
            if (day.state == CheckInDayState.claimed)
              const Icon(Icons.check_circle_rounded, color: Colors.white)
            else
              const CoinIcon(size: 24),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '+${day.coins}',
              style: AppTextStyles.bodyMedium.copyWith(
                color: foreground,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
