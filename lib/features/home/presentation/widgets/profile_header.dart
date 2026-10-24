import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_icon_button.dart';
import '../../../../core/widgets/coin_icon.dart';

/// Home header: avatar, greeting, notification bell and coin balance.
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    required this.name,
    required this.greeting,
    this.avatarUrl,
    this.coins,
    this.hasUnreadNotifications = false,
    this.onAvatarTap,
    this.onNotificationsTap,
    this.onCoinsTap,
    super.key,
  });

  final String name;
  final String greeting;
  final String? avatarUrl;

  /// `null` while the balance is loading.
  final int? coins;
  final bool hasUnreadNotifications;
  final VoidCallback? onAvatarTap;
  final VoidCallback? onNotificationsTap;
  final VoidCallback? onCoinsTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: onAvatarTap,
          child: AppAvatar(
            name: name,
            imageUrl: avatarUrl,
            borderColor: AppColors.textOnDark,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                  text: 'Hi, ',
                  children: [
                    TextSpan(
                      text: name,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.titleLarge.copyWith(
                  color: AppColors.textOnDark,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                greeting,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textOnDarkMuted,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        AppIconButton(
          icon: Icons.notifications_none_rounded,
          tooltip: 'Notifications',
          showBadge: hasUnreadNotifications,
          onPressed: onNotificationsTap,
        ),
        const SizedBox(width: AppSpacing.sm),
        CoinBalanceChip(coins: coins, onTap: onCoinsTap),
      ],
    );
  }
}

/// Outlined pill with the coin balance ("🪙 24 ›").
class CoinBalanceChip extends StatelessWidget {
  const CoinBalanceChip({required this.coins, this.onTap, super.key});

  final int? coins;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final value = coins;
    return Semantics(
      button: true,
      label: value == null ? 'Coin balance loading' : '$value coins, wallet',
      excludeSemantics: true,
      child: Material(
        type: MaterialType.transparency,
        shape: const StadiumBorder(
          side: BorderSide(color: Color(0x99FFFFFF), width: 1.2),
        ),
        child: InkWell(
          onTap: onTap,
          customBorder: const StadiumBorder(),
          child: SizedBox(
            height: AppSizes.headerIconButton,
            child: Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.xs + 2,
                right: AppSpacing.xs,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CoinIcon(size: 28),
                  const SizedBox(width: AppSpacing.sm),
                  AnimatedSwitcher(
                    duration: AppDurations.medium,
                    child: Text(
                      value == null ? '—' : Formatters.compact(value),
                      key: ValueKey(value),
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.textOnDark,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textOnDark,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
