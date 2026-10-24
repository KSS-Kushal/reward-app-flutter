import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/feature_icon.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/wallet.dart';
import '../transaction_visuals.dart';

/// One row of the transaction history.
class TransactionItem extends StatelessWidget {
  const TransactionItem({required this.transaction, this.onTap, super.key});

  final Transaction transaction;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tx = transaction;
    final amountColor = tx.status == TransactionStatus.failed
        ? AppColors.textTertiary
        : tx.isCredit
        ? AppColors.success
        : AppColors.textPrimary;

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          FeatureIcon(visual: tx.source.visual, size: 44),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  Formatters.dateTime(tx.createdAt),
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${tx.isCredit ? '+' : '-'}${Formatters.number(tx.amount)}',
                style: AppTextStyles.titleMedium.copyWith(color: amountColor),
              ),
              if (tx.status != TransactionStatus.completed)
                Text(
                  tx.status.label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: tx.status.color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet with the full details of a transaction.
class TransactionDetailsSheet extends StatelessWidget {
  const TransactionDetailsSheet({
    required this.transaction,
    this.wallet,
    super.key,
  });

  final Transaction transaction;
  final Wallet? wallet;

  static Future<void> show(
    BuildContext context,
    Transaction transaction, {
    Wallet? wallet,
  }) => showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    builder: (_) =>
        TransactionDetailsSheet(transaction: transaction, wallet: wallet),
  );

  @override
  Widget build(BuildContext context) {
    final tx = transaction;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xxl,
          0,
          AppSpacing.xxl,
          AppSpacing.xxl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FeatureIcon(visual: tx.source.visual, size: 64),
            const SizedBox(height: AppSpacing.md),
            Text(
              '${tx.isCredit ? '+' : '-'}${Formatters.number(tx.amount)} coins',
              style: AppTextStyles.headlineMedium,
            ),
            if (wallet != null && wallet!.coinsPerCurrencyUnit > 0)
              Text(
                '≈ ${wallet!.currencySymbol}'
                '${(tx.amount / wallet!.coinsPerCurrencyUnit).toStringAsFixed(2)}',
                style: AppTextStyles.bodySmall,
              ),
            const SizedBox(height: AppSpacing.xl),
            _DetailRow(label: 'Title', value: tx.title),
            if (tx.description != null)
              _DetailRow(label: 'Details', value: tx.description!),
            _DetailRow(
              label: 'Status',
              value: tx.status.label,
              valueColor: tx.status.color,
            ),
            _DetailRow(label: 'Date', value: Formatters.dateTime(tx.createdAt)),
            _DetailRow(label: 'Transaction ID', value: tx.id),
            if (tx.reference != null)
              _DetailRow(label: 'Reference', value: tx.reference!),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Flexible(
            flex: 2,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
