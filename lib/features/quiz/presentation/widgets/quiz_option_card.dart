import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';

enum QuizOptionState { idle, selected, correct, incorrect }

/// A selectable answer ("A  Canberra").
class QuizOptionCard extends StatelessWidget {
  const QuizOptionCard({
    required this.label,
    required this.text,
    this.state = QuizOptionState.idle,
    this.accentColor = AppColors.primary,
    this.onTap,
    super.key,
  });

  /// Option letter, e.g. "A".
  final String label;
  final String text;
  final QuizOptionState state;
  final Color accentColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final (border, background, badge) = switch (state) {
      QuizOptionState.idle => (
        AppColors.border,
        AppColors.surface,
        AppColors.surfaceMuted,
      ),
      QuizOptionState.selected => (
        accentColor,
        accentColor.withValues(alpha: 0.08),
        accentColor,
      ),
      QuizOptionState.correct => (
        AppColors.success,
        AppColors.success.withValues(alpha: 0.08),
        AppColors.success,
      ),
      QuizOptionState.incorrect => (
        AppColors.error,
        AppColors.error.withValues(alpha: 0.08),
        AppColors.error,
      ),
    };
    final badgeText = state == QuizOptionState.idle
        ? AppColors.textPrimary
        : Colors.white;

    return Semantics(
      button: true,
      selected: state == QuizOptionState.selected,
      label: 'Option $label: $text',
      excludeSemantics: true,
      child: Material(
        color: background,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.lgAll,
          side: BorderSide(color: border, width: 1.5),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.lgAll,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: AppDurations.fast,
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: badge,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    label,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: badgeText,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: Text(text, style: AppTextStyles.bodyLarge)),
                if (state == QuizOptionState.correct)
                  const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.success,
                  ),
                if (state == QuizOptionState.incorrect)
                  const Icon(Icons.cancel_rounded, color: AppColors.error),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
