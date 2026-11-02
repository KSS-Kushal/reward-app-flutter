import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/coin_icon.dart';
import '../../domain/entities/reward_claim.dart';
import '../providers/reward_claim_controller.dart';

/// Shows coins that are won but not yet credited, with a button to watch a
/// rewarded ad and collect them. Returns the [ClaimedReward] once the coins
/// are in the wallet, or `null` if the user chose "Later".
class WatchAdRewardDialog extends ConsumerWidget {
  const WatchAdRewardDialog({
    required this.reward,
    required this.title,
    this.message,
    super.key,
  });

  final PendingReward reward;
  final String title;
  final String? message;

  static Future<ClaimedReward?> show(
    BuildContext context, {
    required PendingReward reward,
    required String title,
    String? message,
  }) {
    HapticFeedback.mediumImpact();
    return showDialog<ClaimedReward>(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          WatchAdRewardDialog(reward: reward, title: title, message: message),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = rewardClaimProvider(reward);
    final state = ref.watch(provider);
    final result = state.result;
    final collected = result != null;

    return PopScope(
      canPop: !state.isBusy,
      child: Dialog(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  const CoinIcon(size: 84),
                  if (collected)
                    const Positioned(
                      right: -4,
                      bottom: -4,
                      child: Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.success,
                        size: 32,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                collected ? 'Coins added!' : title,
                textAlign: TextAlign.center,
                style: AppTextStyles.titleLarge,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '+${Formatters.number(reward.coins)} coins',
                style: AppTextStyles.headlineMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                collected
                    ? result.message
                    : message ??
                          'Watch a short ad to add these coins to your wallet.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              if (state.message != null) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  state.message!,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              if (collected)
                AppButton(
                  label: 'Awesome!',
                  onPressed: () => Navigator.of(context).pop(result),
                )
              else ...[
                AppButton(
                  label: state.adWatched ? 'Try again' : 'Watch ad & collect',
                  icon: state.adWatched
                      ? null
                      : const Icon(Icons.play_circle_fill_rounded),
                  isLoading: state.isBusy,
                  onPressed: ref.read(provider.notifier).watchAdAndCollect,
                ),
                const SizedBox(height: AppSpacing.xs),
                TextButton(
                  onPressed: state.isBusy
                      ? null
                      : () => Navigator.of(context).pop(),
                  child: const Text('Later'),
                ),
                Text(
                  'Uncollected coins expire at midnight.',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
