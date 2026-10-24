import 'package:flutter_test/flutter_test.dart';
import 'package:kavodnik/core/errors/errors.dart';
import 'package:kavodnik/features/wallet/data/datasources/mock_wallet_ledger.dart';
import 'package:kavodnik/features/wallet/data/datasources/wallet_mock_data_source.dart';
import 'package:kavodnik/features/wallet/data/repositories/wallet_repository_impl.dart';
import 'package:kavodnik/features/wallet/domain/entities/transaction.dart';
import 'package:kavodnik/features/wallet/domain/usecases/wallet_usecases.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  setUpAll(disableMockLatency);

  late MockWalletLedger ledger;
  late WalletRepositoryImpl repository;

  setUp(() {
    ledger = MockWalletLedger();
    repository = WalletRepositoryImpl(WalletMockDataSource(ledger));
  });

  test('balance excludes pending credits', () async {
    final before = (await repository.getWallet()).balance;
    ledger.credit(
      source: TransactionSource.shopping,
      title: 'Cashback',
      amount: 100,
      status: TransactionStatus.pending,
    );
    final wallet = await repository.getWallet();
    expect(wallet.balance, before);
    expect(wallet.pendingCoins, greaterThanOrEqualTo(100));
  });

  test('transactions are paginated newest first', () async {
    final first = await repository.getTransactions(pageSize: 4);
    final second = await repository.getTransactions(page: 2, pageSize: 4);
    expect(first.items, hasLength(4));
    expect(first.hasMore, isTrue);
    expect(
      first.items.first.createdAt.isAfter(first.items.last.createdAt),
      isTrue,
    );
    expect(second.items.first.id, isNot(first.items.first.id));
  });

  group('RedeemCoins', () {
    late RedeemCoins redeem;

    setUp(() => redeem = RedeemCoins(repository));

    test('rejects amounts below the option minimum', () async {
      final wallet = await repository.getWallet();
      final option = (await repository.getRedeemOptions()).first;
      expect(
        () => redeem(
          wallet: wallet,
          option: option,
          coins: option.minCoins - 1,
          accountDetails: 'me@upi',
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('requires account details when the option needs them', () async {
      final wallet = await repository.getWallet();
      final upi = (await repository.getRedeemOptions()).first;
      expect(upi.accountLabel, isNotNull);
      expect(
        () => redeem(wallet: wallet, option: upi, coins: upi.minCoins),
        throwsA(isA<ValidationException>()),
      );
    });

    test('debits the wallet as a pending payout', () async {
      final wallet = await repository.getWallet();
      final upi = (await repository.getRedeemOptions()).first;
      final tx = await redeem(
        wallet: wallet,
        option: upi,
        coins: upi.minCoins,
        accountDetails: 'me@upi',
      );
      expect(tx.type, TransactionType.debit);
      expect(tx.status, TransactionStatus.pending);
      expect(
        (await repository.getWallet()).balance,
        wallet.balance - upi.minCoins,
      );
    });
  });
}
