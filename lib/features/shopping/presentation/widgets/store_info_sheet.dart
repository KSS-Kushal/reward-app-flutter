import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/merchant.dart';
import 'merchant_widgets.dart';

/// Platform details: reward rate, description, offers and terms.
class StoreInfoSheet extends StatelessWidget {
  const StoreInfoSheet({
    required this.merchant,
    this.scrollController,
    super.key,
  });

  final Merchant merchant;
  final ScrollController? scrollController;

  static Future<void> show(BuildContext context, Merchant merchant) =>
      showModalBottomSheet<void>(
        context: context,
        useRootNavigator: true,
        isScrollControlled: true,
        builder: (_) => DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          builder: (context, controller) =>
              StoreInfoSheet(merchant: merchant, scrollController: controller),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        0,
        AppSpacing.xl,
        AppSpacing.xxl,
      ),
      children: [
        Row(
          children: [
            MerchantLogo(merchant: merchant, size: 56),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(merchant.name, style: AppTextStyles.titleLarge),
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
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Text(merchant.description, style: AppTextStyles.bodyMedium),
        if (merchant.offers.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xl),
          const Text('Offers', style: AppTextStyles.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          for (final offer in merchant.offers) ...[
            _OfferTile(offer: offer),
            const SizedBox(height: AppSpacing.sm),
          ],
        ],
        if (merchant.terms.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          const Text('Terms', style: AppTextStyles.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          for (final term in merchant.terms)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('•  '),
                  Expanded(child: Text(term, style: AppTextStyles.bodySmall)),
                ],
              ),
            ),
        ],
      ],
    );
  }
}

class _OfferTile extends StatelessWidget {
  const _OfferTile({required this.offer});

  final Offer offer;

  @override
  Widget build(BuildContext context) {
    final code = offer.couponCode;
    return AppCard(
      color: AppColors.surfaceMuted,
      shadow: null,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            offer.title,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(offer.description, style: AppTextStyles.bodySmall),
          if (offer.expiresAt != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Valid till ${Formatters.date(offer.expiresAt!)}',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
          if (code != null) ...[
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton.icon(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: code));
                if (context.mounted) context.showSnack('Coupon $code copied');
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 36),
                shape: const StadiumBorder(),
              ),
              icon: const Icon(Icons.copy_rounded, size: 16),
              label: Text(code),
            ),
          ],
        ],
      ),
    );
  }
}
