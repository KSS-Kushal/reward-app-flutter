import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/coin_icon.dart';

/// Celebration dialog shown after any activity that awards coins.
class RewardResultDialog extends StatefulWidget {
  const RewardResultDialog({
    required this.title,
    required this.coins,
    this.message,
    this.actionLabel = 'Awesome!',
    super.key,
  });

  final String title;
  final int coins;
  final String? message;
  final String actionLabel;

  static Future<void> show(
    BuildContext context, {
    required String title,
    required int coins,
    String? message,
    String actionLabel = 'Awesome!',
  }) {
    if (coins > 0) HapticFeedback.mediumImpact();
    return showDialog<void>(
      context: context,
      builder: (_) => RewardResultDialog(
        title: title,
        coins: coins,
        message: message,
        actionLabel: actionLabel,
      ),
    );
  }

  @override
  State<RewardResultDialog> createState() => _RewardResultDialogState();
}

class _RewardResultDialogState extends State<RewardResultDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppDurations.slow,
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final won = widget.coins > 0;
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: CurvedAnimation(
                parent: _controller,
                curve: Curves.elasticOut,
              ),
              child: won
                  ? const CoinIcon(size: 84)
                  : const Icon(
                      Icons.sentiment_dissatisfied_rounded,
                      size: 84,
                      color: AppColors.textTertiary,
                    ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: AppTextStyles.titleLarge,
            ),
            if (won) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                '+${Formatters.number(widget.coins)} coins',
                style: AppTextStyles.headlineMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
            if (widget.message != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                widget.message!,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: widget.actionLabel,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
