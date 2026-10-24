import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/feature_icon.dart';
import '../../domain/entities/app_notification.dart';

extension NotificationTypeVisual on NotificationType {
  FeatureVisual get visual => switch (this) {
    NotificationType.reward => const FeatureVisual(
      icon: Icons.card_giftcard_rounded,
      color: AppColors.primary,
    ),
    NotificationType.referral => const FeatureVisual(
      icon: Icons.group_add_rounded,
      color: AppColors.inviteRing,
    ),
    NotificationType.promotion => const FeatureVisual(
      icon: Icons.local_offer_rounded,
      color: AppColors.spinAction,
    ),
    NotificationType.system => const FeatureVisual(
      icon: Icons.notifications_rounded,
      color: AppColors.info,
    ),
  };
}

class NotificationItem extends StatelessWidget {
  const NotificationItem({
    required this.notification,
    this.onTap,
    this.now,
    super.key,
  });

  final AppNotification notification;
  final VoidCallback? onTap;

  /// Reference time for relative timestamps (injectable for tests).
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final unread = !notification.isRead;
    return Semantics(
      label: unread ? 'Unread notification' : null,
      child: AppCard(
        onTap: onTap,
        color: unread ? AppColors.surface : AppColors.surfaceMuted,
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FeatureIcon(visual: notification.type.visual, size: 40),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: unread ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    notification.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    Formatters.relative(notification.createdAt, now: now),
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            if (unread)
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(top: AppSpacing.xs),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
