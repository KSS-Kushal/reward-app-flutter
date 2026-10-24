import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/core_providers.dart';
import '../../wallet/di/wallet_dependencies.dart';
import '../data/datasources/rewards_mock_data_source.dart';
import '../data/datasources/rewards_remote_data_source.dart';
import '../data/repositories/rewards_repository_impl.dart';
import '../domain/repositories/rewards_repository.dart';
import '../domain/usecases/rewards_usecases.dart';

final rewardsRemoteDataSourceProvider = Provider<RewardsRemoteDataSource>((
  ref,
) {
  if (ref.watch(useMockApiProvider)) {
    return RewardsMockDataSource(ref.watch(mockWalletLedgerProvider));
  }
  return RewardsApiDataSource(ref.watch(apiClientProvider));
});

final rewardsRepositoryProvider = Provider<RewardsRepository>(
  (ref) => RewardsRepositoryImpl(ref.watch(rewardsRemoteDataSourceProvider)),
);

final getDailyRewardsProvider = Provider(
  (ref) => GetDailyRewards(ref.watch(rewardsRepositoryProvider)),
);
final getRewardSummaryProvider = Provider(
  (ref) => GetRewardSummary(ref.watch(rewardsRepositoryProvider)),
);
final getRewardHistoryProvider = Provider(
  (ref) => GetRewardHistory(ref.watch(rewardsRepositoryProvider)),
);
final getCheckInStatusProvider = Provider(
  (ref) => GetCheckInStatus(ref.watch(rewardsRepositoryProvider)),
);
final claimCheckInProvider = Provider(
  (ref) => ClaimCheckIn(ref.watch(rewardsRepositoryProvider)),
);
final getSpinWheelProvider = Provider(
  (ref) => GetSpinWheel(ref.watch(rewardsRepositoryProvider)),
);
final spinWheelProvider = Provider(
  (ref) => SpinWheel(ref.watch(rewardsRepositoryProvider)),
);
final getScratchCardProvider = Provider(
  (ref) => GetScratchCard(ref.watch(rewardsRepositoryProvider)),
);
final revealScratchCardProvider = Provider(
  (ref) => RevealScratchCard(ref.watch(rewardsRepositoryProvider)),
);
final getCaptchaProvider = Provider(
  (ref) => GetCaptcha(ref.watch(rewardsRepositoryProvider)),
);
final submitCaptchaProvider = Provider(
  (ref) => SubmitCaptcha(ref.watch(rewardsRepositoryProvider)),
);
