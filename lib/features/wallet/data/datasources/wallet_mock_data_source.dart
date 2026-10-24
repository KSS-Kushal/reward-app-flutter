import '../../../../core/errors/errors.dart';
import '../../../../core/mock/mock_latency.dart';
import '../../../../shared/models/paginated_list.dart';
import '../../domain/entities/redeem_option.dart';
import '../../domain/entities/transaction.dart';
import '../models/redeem_option_model.dart';
import '../models/transaction_model.dart';
import '../models/wallet_model.dart';
import 'mock_wallet_ledger.dart';
import 'wallet_remote_data_source.dart';

class WalletMockDataSource implements WalletRemoteDataSource {
  const WalletMockDataSource(this._ledger);

  final MockWalletLedger _ledger;

  static const _redeemOptions = [
    RedeemOptionModel(
      id: 'redeem_upi',
      method: RedeemMethod.upi,
      name: 'UPI Transfer',
      description: 'Send money to any UPI ID',
      minCoins: 1000,
      processingTime: 'Within 24 hours',
      accountLabel: 'UPI ID',
    ),
    RedeemOptionModel(
      id: 'redeem_paytm',
      method: RedeemMethod.paytm,
      name: 'Paytm Wallet',
      description: 'Add balance to your Paytm wallet',
      minCoins: 1000,
      processingTime: 'Within 24 hours',
      accountLabel: 'Paytm mobile number',
    ),
    RedeemOptionModel(
      id: 'redeem_amazon',
      method: RedeemMethod.amazonPay,
      name: 'Amazon Pay Gift Card',
      description: 'Gift card code sent to your email',
      minCoins: 2500,
      processingTime: 'Within 48 hours',
    ),
    RedeemOptionModel(
      id: 'redeem_play',
      method: RedeemMethod.googlePlay,
      name: 'Google Play Code',
      description: 'Redeem code for apps and games',
      minCoins: 5000,
      processingTime: 'Within 48 hours',
    ),
  ];

  @override
  Future<WalletModel> getWallet() async {
    await MockLatency.simulate();
    return _ledger.wallet;
  }

  @override
  Future<PaginatedList<TransactionModel>> getTransactions({
    required int page,
    required int pageSize,
  }) async {
    await MockLatency.simulate();
    final all = _ledger.transactions;
    final start = (page - 1) * pageSize;
    final items = start >= all.length
        ? <TransactionModel>[]
        : all.sublist(start, (start + pageSize).clamp(0, all.length));
    return PaginatedList(
      items: items,
      page: page,
      pageSize: pageSize,
      totalCount: all.length,
      hasMore: start + pageSize < all.length,
    );
  }

  @override
  Future<List<RedeemOptionModel>> getRedeemOptions() async {
    await MockLatency.simulate();
    return _redeemOptions;
  }

  @override
  Future<TransactionModel> redeem({
    required String optionId,
    required int coins,
    String? accountDetails,
  }) async {
    await MockLatency.simulate();
    final option = _redeemOptions.firstWhere(
      (o) => o.id == optionId,
      orElse: () => throw const ValidationException(
        message: 'This redemption option is no longer available.',
      ),
    );
    if (coins < option.minCoins) {
      throw ValidationException(
        message: 'The minimum for ${option.name} is ${option.minCoins} coins.',
      );
    }
    if (coins > _ledger.wallet.balance) {
      throw const ValidationException(
        message: "You don't have enough coins for this redemption.",
      );
    }
    return _ledger.debit(
      source: TransactionSource.redeem,
      title: 'Redeemed to ${option.name}',
      amount: coins,
      description: accountDetails,
      reference: 'PAYOUT-${DateTime.now().millisecondsSinceEpoch % 100000}',
      status: TransactionStatus.pending,
    );
  }
}
