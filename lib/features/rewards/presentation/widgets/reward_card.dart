import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/feature_icon.dart';
import '../../domain/entities/reward_task.dart';

/// Daily reward tile from the Figma "Daily Rewards" row: pastel surface,
/// illustration, two-line title and a coloured pill call-to-action.
///
/// Supports enabled, completed, locked and loading ([isLoading]) states.
class RewardCard extends StatelessWidget {
  const RewardCard({
    required this.title,
    required this.actionLabel,
    required this.visual,
    required this.surfaceColor,
    required this.actionColor,
    this.status = RewardTaskStatus.available,
    this.subtitle,
    this.rewardCoins,
    this.onPressed,
    this.isLoading = false,
    super.key,
  });

  final String title;
  final String? subtitle;
  final String actionLabel;
  final FeatureVisual visual;
  final Color surfaceColor;
  final Color actionColor;
  final RewardTaskStatus status;
  final int? rewardCoins;
  final VoidCallback? onPressed;
  final bool isLoading;

  bool get _enabled =>
      !isLoading && status == RewardTaskStatus.available && onPressed != null;

  String get _label => switch (status) {
    RewardTaskStatus.completed => 'Done',
    RewardTaskStatus.locked => 'Locked',
    RewardTaskStatus.available => actionLabel,
  };

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: '$title, ${_label.toLowerCase()}',
      child: Material(
        color: surfaceColor,
        borderRadius: AppRadius.lgAll,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          // Completed tasks stay tappable so users can view their result.
          onTap: status == RewardTaskStatus.locked || isLoading
              ? null
              : onPressed,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.sm,
            ),
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Opacity(
                      opacity: status == RewardTaskStatus.locked ? 0.5 : 1,
                      child: FeatureIcon(visual: visual, size: 48),
                    ),
                    if (status != RewardTaskStatus.available)
                      Positioned(
                        right: -6,
                        bottom: -4,
                        child: _StatusBadge(status: status),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Expanded(
                  child: Center(
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.cardTitle,
                    ),
                  ),
                ),
                if (subtitle != null) ...[
                  Text(
                    subtitle!,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                ],
                const SizedBox(height: AppSpacing.xs),
                isLoading
                    ? const SkeletonBox(
                        height: AppSizes.pillButtonHeight,
                        borderRadius: AppRadius.pillAll,
                      )
                    : AppPillButton(
                        label: _label,
                        color: actionColor,
                        onPressed: _enabled ? onPressed : null,
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final RewardTaskStatus status;

  @override
  Widget build(BuildContext context) {
    final completed = status == RewardTaskStatus.completed;
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: completed ? AppColors.success : AppColors.textSecondary,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      child: Icon(
        completed ? Icons.check_rounded : Icons.lock_rounded,
        size: 12,
        color: Colors.white,
      ),
    );
  }
}
