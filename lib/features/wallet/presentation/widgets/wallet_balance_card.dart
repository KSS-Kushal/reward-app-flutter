import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/coin_icon.dart';
import '../../domain/entities/wallet.dart';

/// Balance summary shown on the dark header of the wallet screen.
class WalletBalanceCard extends StatelessWidget {
  const WalletBalanceCard({required this.wallet, this.onRedeem, super.key});

  final Wallet wallet;
  final VoidCallback? onRedeem;

  @override
  Widget build(BuildContext context) {
    final currencyValue = wallet.balanceInCurrency.toStringAsFixed(2);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: AppRadius.xlAll,
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Available balance',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textOnDarkMuted,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    const CoinIcon(size: 30),
                    const SizedBox(width: AppSpacing.sm),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          Formatters.number(wallet.balance),
                          style: AppTextStyles.amount,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '≈ ${wallet.currencySymbol}$currencyValue',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textOnDarkMuted,
                  ),
                ),
              ],
            ),
          ),
          if (onRedeem != null) ...[
            const SizedBox(width: AppSpacing.md),
            FilledButton(
              onPressed: wallet.canRedeem ? onRedeem : null,
              style: FilledButton.styleFrom(
                minimumSize: const Size(96, 44),
                backgroundColor: AppColors.surface,
                foregroundColor: AppColors.primary,
                disabledBackgroundColor: Colors.white.withValues(alpha: 0.3),
                disabledForegroundColor: AppColors.textOnDarkMuted,
                shape: const StadiumBorder(),
              ),
              child: const Text('Redeem'),
            ),
          ],
        ],
      ),
    );
  }
}

/// Earned / pending / redeemed figures under the balance.
class WalletStatsRow extends StatelessWidget {
  const WalletStatsRow({required this.wallet, super.key});

  final Wallet wallet;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _Stat(
            label: 'Total earned',
            value: wallet.totalEarned,
            color: AppColors.success,
            icon: Icons.trending_up_rounded,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _Stat(
            label: 'Pending',
            value: wallet.pendingCoins,
            color: AppColors.warning,
            icon: Icons.schedule_rounded,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _Stat(
            label: 'Redeemed',
            value: wallet.totalRedeemed,
            color: AppColors.info,
            icon: Icons.account_balance_rounded,
          ),
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final int value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.lgAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: AppSizes.iconMd),
          const SizedBox(height: AppSpacing.sm),
          Text(
            Formatters.compact(value),
            style: AppTextStyles.titleMedium,
            maxLines: 1,
          ),
          Text(
            label,
            style: AppTextStyles.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
