import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/coin_icon.dart';
import '../../domain/entities/article.dart';

class ArticleCard extends StatelessWidget {
  const ArticleCard({required this.article, this.onTap, super.key});

  final Article article;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: AppRadius.mdAll,
            child: AppNetworkImage(
              url: article.imageUrl,
              width: 88,
              height: 88,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  article.category.name.toUpperCase(),
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  article.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    const Icon(
                      Icons.schedule_rounded,
                      size: 14,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(width: AppSpacing.xxs),
                    Text(
                      '${article.readTimeMinutes} min read',
                      style: AppTextStyles.bodySmall,
                    ),
                    const Spacer(),
                    _RewardBadge(article: article),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RewardBadge extends StatelessWidget {
  const _RewardBadge({required this.article});

  final Article article;

  @override
  Widget build(BuildContext context) {
    if (!article.hasReward) return const SizedBox.shrink();
    if (article.rewardStatus == ArticleRewardStatus.claimed) {
      return Text(
        'Claimed',
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.success,
          fontWeight: FontWeight.w600,
        ),
      );
    }
    return CoinAmount(
      amount: article.rewardCoins,
      showSign: true,
      iconSize: 16,
      style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600),
    );
  }
}
