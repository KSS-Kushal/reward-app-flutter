import '../../../../shared/models/paginated_list.dart';
import '../../domain/entities/redeem_option.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/wallet.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../datasources/wallet_remote_data_source.dart';

class WalletRepositoryImpl implements WalletRepository {
  const WalletRepositoryImpl(this._remote);

  final WalletRemoteDataSource _remote;

  @override
  Future<Wallet> getWallet() => _remote.getWallet();

  @override
  Future<PaginatedList<Transaction>> getTransactions({
    int page = 1,
    int pageSize = 20,
  }) => _remote.getTransactions(page: page, pageSize: pageSize);

  @override
  Future<List<RedeemOption>> getRedeemOptions() => _remote.getRedeemOptions();

  @override
  Future<Transaction> redeem({
    required String optionId,
    required int coins,
    String? accountDetails,
  }) => _remote.redeem(
    optionId: optionId,
    coins: coins,
    accountDetails: accountDetails,
  );
}
