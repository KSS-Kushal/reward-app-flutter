import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/widgets/feature_icon.dart';

/// Card with an illustration, title, two-line description and a round
/// chevron, as used by the "Earn More" and "Quiz Zone" sections.
class FeatureTileCard extends StatelessWidget {
  const FeatureTileCard({
    required this.title,
    required this.subtitle,
    required this.visual,
    required this.chevronColor,
    this.backgroundColor = AppColors.surface,
    this.chevronBackground,
    this.onTap,
    this.badge,
    super.key,
  });

  final String title;
  final String subtitle;
  final FeatureVisual visual;
  final Color backgroundColor;

  /// Colour of the chevron icon.
  final Color chevronColor;

  /// Fill of the chevron circle (defaults to [chevronColor]).
  final Color? chevronBackground;
  final VoidCallback? onTap;

  /// Optional overlay such as a "Done" tag.
  final Widget? badge;

  @override
  Widget build(BuildContext context) {
    final circleFill = chevronBackground ?? chevronColor;
    final iconColor = chevronBackground == null ? Colors.white : chevronColor;
    return Semantics(
      button: true,
      label: '$title. $subtitle',
      excludeSemantics: true,
      child: Material(
        color: backgroundColor,
        borderRadius: AppRadius.lgAll,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FeatureIcon(visual: visual, size: 44),
                    const Spacer(),
                    ?badge,
                  ],
                ),
                const Spacer(),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.cardTitle.copyWith(fontSize: 16),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: circleFill,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.chevron_right_rounded,
                        size: 20,
                        color: iconColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
