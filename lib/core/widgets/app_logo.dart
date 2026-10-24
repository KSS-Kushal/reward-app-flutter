import 'package:flutter/material.dart';

import '../../app/config/app_config.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../app/theme/app_shadows.dart';
import '../../app/theme/app_text_styles.dart';
import 'coin_icon.dart';

/// Brand mark: coin badge with the app name.
class AppLogo extends StatelessWidget {
  const AppLogo({this.size = 84, this.showName = true, super.key});

  final double size;
  final bool showName;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(size * 0.28),
            boxShadow: AppShadows.card,
          ),
          alignment: Alignment.center,
          child: CoinIcon(size: size * 0.6),
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
