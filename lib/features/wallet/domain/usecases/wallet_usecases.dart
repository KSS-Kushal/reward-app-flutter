import '../../../../core/errors/errors.dart';
import '../../../../shared/models/paginated_list.dart';
import '../entities/redeem_option.dart';
import '../entities/transaction.dart';
import '../entities/wallet.dart';
import '../repositories/wallet_repository.dart';

class GetWallet {
  const GetWallet(this._repository);
  final WalletRepository _repository;

  Future<Wallet> call() => _repository.getWallet();
}

class GetTransactions {
  const GetTransactions(this._repository);
  final WalletRepository _repository;

  Future<PaginatedList<Transaction>> call({int page = 1, int pageSize = 20}) =>
      _repository.getTransactions(page: page, pageSize: pageSize);
}

class GetRedeemOptions {
  const GetRedeemOptions(this._repository);
  final WalletRepository _repository;

  Future<List<RedeemOption>> call() => _repository.getRedeemOptions();
}

/// Validates obvious input mistakes before calling the backend. The backend
/// still performs the authoritative balance and limit checks.
class RedeemCoins {
  const RedeemCoins(this._repository);
  final WalletRepository _repository;

  Future<Transaction> call({
    required Wallet wallet,
    required RedeemOption option,
    required int coins,
    String? accountDetails,
  }) {
    if (coins < option.minCoins) {
      throw ValidationException(
        message: 'The minimum for ${option.name} is ${option.minCoins} coins.',
      );
    }
    if (coins > wallet.balance) {
      throw const ValidationException(
        message: "You don't have enough coins for this redemption.",
      );
    }
    final details = accountDetails?.trim();
    if (option.accountLabel != null && (details == null || details.isEmpty)) {
      throw ValidationException(
        message: 'Please enter your ${option.accountLabel}.',
      );
    }
    return _repository.redeem(
      optionId: option.id,
      coins: coins,
      accountDetails: details,
    );
  }
}
