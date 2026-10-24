import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/core_providers.dart';
import '../../authentication/di/auth_dependencies.dart';
import '../../wallet/di/wallet_dependencies.dart';
import '../data/datasources/profile_mock_data_source.dart';
import '../data/datasources/profile_remote_data_source.dart';
import '../data/repositories/profile_repository_impl.dart';
import '../domain/repositories/profile_repository.dart';
import '../domain/usecases/profile_usecases.dart';

final profileRemoteDataSourceProvider = Provider<ProfileRemoteDataSource>((
  ref,
) {
  if (ref.watch(useMockApiProvider)) {
    return ProfileMockDataSource(
      userStore: ref.watch(mockUserStoreProvider),
      ledger: ref.watch(mockWalletLedgerProvider),
    );
  }
  return ProfileApiDataSource(ref.watch(apiClientProvider));
});

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepositoryImpl(ref.watch(profileRemoteDataSourceProvider)),
);

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepositoryImpl(ref.watch(localStorageProvider)),
);

final getProfileStatsProvider = Provider(
  (ref) => GetProfileStats(ref.watch(profileRepositoryProvider)),
);
final updateProfileProvider = Provider(
  (ref) => UpdateProfile(ref.watch(profileRepositoryProvider)),
);
