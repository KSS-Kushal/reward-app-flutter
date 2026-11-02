import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/coin_icon.dart';
import '../../domain/entities/reward_claim.dart';

/// Reminds the user of coins won earlier that still need an ad.
class PendingRewardCard extends StatelessWidget {
  const PendingRewardCard({
    required this.reward,
    required this.onCollect,
    this.count = 1,
    super.key,
  });

  final PendingReward reward;
  final VoidCallback onCollect;

  /// How many uncollected prizes there are in total.
  final int count;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: AppColors.primaryLight,
      shadow: null,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          const CoinIcon(size: 36),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '+${Formatters.number(reward.coins)} coins waiting',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryDark,
                  ),
                ),
                Text(
                  count > 1
                      ? 'Watch an ad to collect · $count prizes left'
                      : 'Watch an ad to collect',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          AppPillButton(
            label: 'Collect',
            color: AppColors.primary,
            expand: false,
            onPressed: onCollect,
          ),
        ],
      ),
    );
  }
}
