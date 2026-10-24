import 'package:flutter/material.dart';

import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';

/// Circular shortcut with a label underneath ("Rate Us", "Invite"...).
class QuickActionItem extends StatelessWidget {
  const QuickActionItem({
    required this.label,
    required this.icon,
    required this.fillColor,
    required this.ringColor,
    this.onTap,
    super.key,
  });

  final String label;
  final IconData icon;
  final Color fillColor;
  final Color ringColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.mdAll,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: AppSizes.quickActionCircle,
                height: AppSizes.quickActionCircle,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [Colors.white, fillColor],
                    radius: 0.9,
                  ),
                  border: Border.all(color: ringColor, width: 1.5),
                ),
                child: Icon(icon, color: ringColor, size: 30),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppTextStyles.labelMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
