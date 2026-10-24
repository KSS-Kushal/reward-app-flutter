import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/color_utils.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../domain/entities/merchant.dart';

/// Store logo, falling back to the brand initial on the brand colour.
class MerchantLogo extends StatelessWidget {
  const MerchantLogo({required this.merchant, this.size = 52, super.key});

  final Merchant merchant;
  final double size;

  @override
  Widget build(BuildContext context) {
    final brand = colorFromHex(merchant.brandColorHex);
    final fallback = Container(
      color: brand,
      alignment: Alignment.center,
      child: Text(
        merchant.name.characters.first,
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.45,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.28),
      child: SizedBox.square(
        dimension: size,
        child: merchant.logoUrl == null
            ? fallback
            : AppNetworkImage(
                url: merchant.logoUrl,
                width: size,
                height: size,
                fallback: fallback,
              ),
      ),
    );
  }
}

/// Grid tile of the Shop & Earn listing.
class MerchantCard extends StatelessWidget {
  const MerchantCard({required this.merchant, this.onTap, super.key});

  final Merchant merchant;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          MerchantLogo(merchant: merchant),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        merchant.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (merchant.isFeatured) ...[
                      const SizedBox(width: AppSpacing.xs),
                      const Icon(
                        Icons.verified_rounded,
                        size: 16,
                        color: AppColors.info,
                      ),
                    ],
                  ],
                ),
                Text(merchant.category.name, style: AppTextStyles.bodySmall),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  merchant.rewardText,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textTertiary,
          ),
        ],
      ),
    );
  }
}
