import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/app_empty_view.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/gradient_page_scaffold.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../shared/components/paginated_list_view.dart';
import '../../domain/entities/wallet.dart';
import '../providers/wallet_providers.dart';
import '../widgets/redeem_sheet.dart';
import '../widgets/transaction_item.dart';
import '../widgets/wallet_balance_card.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  Future<void> _redeem(BuildContext context, Wallet wallet) async {
    final transaction = await RedeemSheet.show(context, wallet);
    if (transaction != null && context.mounted) {
      context.showSnack('Redemption requested. It will be processed shortly.');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallet = ref.watch(walletProvider);
    final transactions = ref.watch(transactionsProvider);

    return GradientPageScaffold(
      title: 'Wallet',
      showBack: false,
      headerBottom: wallet.when(
        data: (data) => WalletBalanceCard(
          wallet: data,
          onRedeem: () => _redeem(context, data),
        ),
        loading: () => const SkeletonBox(height: 128),
        error: (error, _) => AppErrorView(
          error: error,
          compact: true,
          onRetry: () => ref.invalidate(walletProvider),
        ),
      ),
      body: PaginatedListView(
        value: transactions,
        onRefresh: () async {
          ref.invalidate(walletProvider);
          await ref.read(transactionsProvider.notifier).refresh();
        },
        onLoadMore: ref.read(transactionsProvider.notifier).loadMore,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.page,
          AppSpacing.xl,
          AppSpacing.page,
          AppSizes.bottomNavClearance,
        ),
        header: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (wallet.value case final data?) ...[
              WalletStatsRow(wallet: data),
              const SizedBox(height: AppSpacing.xxl),
            ],
            const SectionHeader(
              title: 'Transactions',
              icon: Icons.receipt_long_outlined,
            ),
          ],
        ),
        empty: const AppEmptyView(
          title: 'No transactions yet',
          message: 'Complete daily rewards to start earning coins.',
          icon: Icons.receipt_long_outlined,
        ),
        itemBuilder: (context, transaction) => TransactionItem(
          transaction: transaction,
          onTap: () => TransactionDetailsSheet.show(
            context,
            transaction,
            wallet: wallet.value,
          ),
        ),
      ),
    );
  }
}
