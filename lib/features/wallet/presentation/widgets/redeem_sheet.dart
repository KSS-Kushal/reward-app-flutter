import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/errors/errors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/async_value_view.dart';
import '../../domain/entities/redeem_option.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/wallet.dart';
import '../providers/wallet_providers.dart';
import '../transaction_visuals.dart';

/// Bottom sheet to convert coins into a payout.
class RedeemSheet extends ConsumerStatefulWidget {
  const RedeemSheet({required this.wallet, super.key});

  final Wallet wallet;

  static Future<Transaction?> show(BuildContext context, Wallet wallet) =>
      showModalBottomSheet<Transaction>(
        context: context,
        useRootNavigator: true,
        isScrollControlled: true,
        builder: (_) => RedeemSheet(wallet: wallet),
      );

  @override
  ConsumerState<RedeemSheet> createState() => _RedeemSheetState();
}

class _RedeemSheetState extends ConsumerState<RedeemSheet> {
  final _coinsController = TextEditingController();
  final _accountController = TextEditingController();
  RedeemOption? _selected;

  @override
  void dispose() {
    _coinsController.dispose();
    _accountController.dispose();
    super.dispose();
  }

  void _select(RedeemOption option) {
    setState(() => _selected = option);
    _coinsController.text = option.minCoins.toString();
  }

  Future<void> _submit() async {
    final option = _selected;
    if (option == null) return;
    final transaction = await ref
        .read(redeemControllerProvider.notifier)
        .redeem(
          wallet: widget.wallet,
          option: option,
          coins: int.tryParse(_coinsController.text) ?? 0,
          accountDetails: _accountController.text,
        );
    if (transaction != null && mounted) Navigator.of(context).pop(transaction);
  }

  @override
  Widget build(BuildContext context) {
    final options = ref.watch(redeemOptionsProvider);
    final submission = ref.watch(redeemControllerProvider);
    final selected = _selected;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            0,
            AppSpacing.xl,
            AppSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Redeem coins', style: AppTextStyles.titleLarge),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Available: ${Formatters.number(widget.wallet.balance)} coins',
                style: AppTextStyles.bodySmall,
              ),
              const SizedBox(height: AppSpacing.lg),
              AsyncValueView(
                value: options,
                onRetry: () => ref.invalidate(redeemOptionsProvider),
                data: (items) => Column(
                  children: [
                    for (final option in items)
                      _OptionTile(
                        option: option,
                        selected: option.id == selected?.id,
                        affordable: widget.wallet.balance >= option.minCoins,
                        onTap: () => _select(option),
                      ),
                  ],
                ),
              ),
              if (selected != null) ...[
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  controller: _coinsController,
                  label: 'Coins to redeem',
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.toll_rounded,
                ),
                if (selected.accountLabel != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    controller: _accountController,
                    label: selected.accountLabel,
                    hint: 'Enter your ${selected.accountLabel}',
                  ),
                ],
                if (submission.hasError) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    userMessageFor(submission.error!),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.xl),
                AppButton(
                  label: 'Redeem now',
                  isLoading: submission.isLoading,
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _submit();
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.option,
    required this.selected,
    required this.affordable,
    required this.onTap,
  });

  final RedeemOption option;
  final bool selected;
  final bool affordable;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: selected ? AppColors.primaryLight : AppColors.surfaceMuted,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.lgAll,
          side: BorderSide(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: InkWell(
          onTap: affordable ? onTap : null,
          borderRadius: AppRadius.lgAll,
          child: Opacity(
            opacity: affordable ? 1 : 0.5,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Icon(option.method.icon, color: AppColors.primary),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          option.name,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${option.description} · ${option.processingTime}',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Min ${Formatters.compact(option.minCoins)}',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
