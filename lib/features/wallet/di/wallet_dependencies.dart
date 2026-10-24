import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/core_providers.dart';
import '../data/datasources/mock_wallet_ledger.dart';
import '../data/datasources/wallet_mock_data_source.dart';
import '../data/datasources/wallet_remote_data_source.dart';
import '../data/repositories/wallet_repository_impl.dart';
import '../domain/repositories/wallet_repository.dart';
import '../domain/usecases/wallet_usecases.dart';

/// Shared mock ledger credited by every mock earning activity.
final mockWalletLedgerProvider = Provider<MockWalletLedger>(
  (ref) => MockWalletLedger(),
);

final walletRemoteDataSourceProvider = Provider<WalletRemoteDataSource>((ref) {
  if (ref.watch(useMockApiProvider)) {
    return WalletMockDataSource(ref.watch(mockWalletLedgerProvider));
  }
  return WalletApiDataSource(ref.watch(apiClientProvider));
});

final walletRepositoryProvider = Provider<WalletRepository>(
  (ref) => WalletRepositoryImpl(ref.watch(walletRemoteDataSourceProvider)),
);

final getWalletProvider = Provider(
  (ref) => GetWallet(ref.watch(walletRepositoryProvider)),
);
final getTransactionsProvider = Provider(
  (ref) => GetTransactions(ref.watch(walletRepositoryProvider)),
);
final getRedeemOptionsProvider = Provider(
  (ref) => GetRedeemOptions(ref.watch(walletRepositoryProvider)),
);
final redeemCoinsProvider = Provider(
  (ref) => RedeemCoins(ref.watch(walletRepositoryProvider)),
);
