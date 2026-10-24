import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/core_providers.dart';
import '../../authentication/di/auth_dependencies.dart';
import '../data/datasources/referral_mock_data_source.dart';
import '../data/datasources/referral_remote_data_source.dart';
import '../data/repositories/referral_repository_impl.dart';
import '../domain/repositories/referral_repository.dart';
import '../domain/usecases/referral_usecases.dart';

final referralRemoteDataSourceProvider = Provider<ReferralRemoteDataSource>((
  ref,
) {
  if (ref.watch(useMockApiProvider)) {
    return ReferralMockDataSource(ref.watch(mockUserStoreProvider));
  }
  return ReferralApiDataSource(ref.watch(apiClientProvider));
});

final referralRepositoryProvider = Provider<ReferralRepository>(
  (ref) => ReferralRepositoryImpl(ref.watch(referralRemoteDataSourceProvider)),
);

final getReferralInfoProvider = Provider(
  (ref) => GetReferralInfo(ref.watch(referralRepositoryProvider)),
);
