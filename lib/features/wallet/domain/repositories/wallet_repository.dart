import '../../../../shared/models/paginated_list.dart';
import '../entities/redeem_option.dart';
import '../entities/transaction.dart';
import '../entities/wallet.dart';

abstract interface class WalletRepository {
  Future<Wallet> getWallet();

  Future<PaginatedList<Transaction>> getTransactions({
    int page = 1,
    int pageSize = 20,
  });

  Future<List<RedeemOption>> getRedeemOptions();

  /// Requests a payout. The backend validates balance and limits and returns
  /// the resulting (usually pending) transaction.
  Future<Transaction> redeem({
    required String optionId,
    required int coins,
    String? accountDetails,
  });
}
