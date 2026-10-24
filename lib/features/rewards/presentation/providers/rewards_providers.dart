import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../wallet/presentation/providers/wallet_providers.dart';
import '../../di/rewards_dependencies.dart';
import '../../domain/entities/reward_summary.dart';
import '../../domain/entities/reward_task.dart';

final dailyRewardsProvider = FutureProvider.autoDispose<List<RewardTask>>(
  (ref) => ref.watch(getDailyRewardsProvider).call(),
);

final rewardSummaryProvider = FutureProvider.autoDispose<RewardSummary>(
  (ref) => ref.watch(getRewardSummaryProvider).call(),
);

final rewardHistoryProvider = FutureProvider.autoDispose<List<RewardActivity>>(
  (ref) => ref.watch(getRewardHistoryProvider).call(),
);

/// Refreshes everything that depends on the balance after coins were earned.
void refreshAfterEarning(Ref ref) {
  ref
    ..invalidate(walletProvider)
    ..invalidate(transactionsProvider)
    ..invalidate(dailyRewardsProvider)
    ..invalidate(rewardSummaryProvider)
    ..invalidate(rewardHistoryProvider);
}
