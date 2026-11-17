import 'package:flutter/material.dart';

import '../../app/config/app_config.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../app/theme/app_shadows.dart';
import '../../app/theme/app_text_styles.dart';

/// Brand mark: the app logo with the app name.
class AppLogo extends StatelessWidget {
  const AppLogo({this.size = 84, this.showName = true, super.key});

  static const _asset = 'assets/images/app_logo.png';

  /// Corner radius of the logo artwork, as a fraction of its size.
  static const _cornerRatio = 0.24;

  final double size;
  final bool showName;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size * _cornerRatio),
            boxShadow: AppShadows.card,
          ),
          child: Image.asset(
            _asset,
            width: size,
            height: size,
            semanticLabel: AppConfig.appName,
          ),
        ),
        if (showName) ...[
          const SizedBox(height: AppSpacing.lg),
          Text(
            AppConfig.appName,
            style: AppTextStyles.headlineMedium.copyWith(
              color: AppColors.textOnDark,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ],
    );
  }
}
