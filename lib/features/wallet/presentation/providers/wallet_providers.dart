import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/paginated_list.dart';
import '../../../../shared/models/paginated_state.dart';
import '../../di/wallet_dependencies.dart';
import '../../domain/entities/redeem_option.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/wallet.dart';

/// Current balance; shown in the home header and on the wallet tab.
/// Invalidate it after any action that changes the balance.
final walletProvider = FutureProvider.autoDispose<Wallet>(
  (ref) => ref.watch(getWalletProvider).call(),
);

final transactionsProvider =
    AsyncNotifierProvider.autoDispose<
      TransactionsController,
      PaginatedState<Transaction>
    >(TransactionsController.new);

class TransactionsController extends PaginatedController<Transaction> {
  static const _pageSize = 10;

  @override
  Future<PaginatedList<Transaction>> fetchPage(int page) =>
      ref.read(getTransactionsProvider).call(page: page, pageSize: _pageSize);
}

final redeemOptionsProvider = FutureProvider.autoDispose<List<RedeemOption>>(
  (ref) => ref.watch(getRedeemOptionsProvider).call(),
);

/// Executes a redemption and refreshes balance-dependent data.
final redeemControllerProvider =
    AsyncNotifierProvider.autoDispose<RedeemController, Transaction?>(
      RedeemController.new,
    );

class RedeemController extends AsyncNotifier<Transaction?> {
  @override
  Transaction? build() => null;

  /// Returns the created transaction, or `null` if the request failed (the
  /// error is then available in [state]).
  Future<Transaction?> redeem({
    required Wallet wallet,
    required RedeemOption option,
    required int coins,
    String? accountDetails,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(redeemCoinsProvider)
          .call(
            wallet: wallet,
            option: option,
            coins: coins,
            accountDetails: accountDetails,
          ),
    );
    if (!ref.mounted) return null;
    if (state.hasValue) {
      ref
        ..invalidate(walletProvider)
        ..invalidate(transactionsProvider);
    }
    return state.value;
  }
}
