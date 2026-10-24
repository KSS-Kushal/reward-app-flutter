import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../app/theme/app_text_styles.dart';
import '../utils/formatters.dart';

/// Gold coin with a star, the in-app currency symbol.
class CoinIcon extends StatelessWidget {
  const CoinIcon({this.size = 22, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [AppColors.coinLight, AppColors.coin],
        ),
        border: Border.all(color: const Color(0xFFE09A00), width: size * 0.06),
      ),
      child: Icon(Icons.star_rounded, size: size * 0.7, color: Colors.white),
    );
  }
}

/// Coin icon followed by an amount, e.g. "🪙 +25".
class CoinAmount extends StatelessWidget {
  const CoinAmount({
    required this.amount,
    this.showSign = false,
    this.iconSize = 18,
    this.style,
    super.key,
  });

  final int amount;
  final bool showSign;
  final double iconSize;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final sign = showSign && amount > 0 ? '+' : '';
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CoinIcon(size: iconSize),
        const SizedBox(width: AppSpacing.xs),
        Text(
          '$sign${Formatters.number(amount)}',
          style:
              style ??
              AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

/// Highlighted pill with the coins earned, e.g. on result screens.
class CoinAmountBadge extends StatelessWidget {
  const CoinAmountBadge({required this.amount, super.key});

  final int amount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.coin.withValues(alpha: 0.15),
        borderRadius: AppRadius.pillAll,
      ),
      child: CoinAmount(
        amount: amount,
        showSign: true,
        iconSize: 22,
        style: AppTextStyles.titleMedium,
      ),
    );
  }
}
