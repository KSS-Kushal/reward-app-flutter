import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/ads/ad_models.dart';
import '../../../../core/ads/ad_providers.dart';
import '../../../../core/errors/errors.dart';
import '../../di/rewards_dependencies.dart';
import '../../domain/entities/reward_claim.dart';
import 'rewards_providers.dart';

enum RewardClaimPhase { ready, showingAd, collecting, collected }

@immutable
class RewardClaimState {
  const RewardClaimState({
    this.phase = RewardClaimPhase.ready,
    this.result,
    this.message,
    this.adWatched = false,
  });

  final RewardClaimPhase phase;
  final ClaimedReward? result;

  /// Why the last attempt did not collect the coins.
  final String? message;

  /// The ad was watched but collecting failed: retrying needs no new ad.
  final bool adWatched;

  bool get isBusy =>
      phase == RewardClaimPhase.showingAd ||
      phase == RewardClaimPhase.collecting;
}

/// "Watch ad → collect coins" for one [PendingReward].
final rewardClaimProvider = NotifierProvider.autoDispose
    .family<RewardClaimController, RewardClaimState, PendingReward>(
      RewardClaimController.new,
    );

class RewardClaimController extends Notifier<RewardClaimState> {
  RewardClaimController(this.reward);

  final PendingReward reward;
  AdUnit? _watchedOn;

  static AdPlacement placementFor(RewardClaimSource source) => switch (source) {
    RewardClaimSource.checkIn => AdPlacement.checkIn,
    RewardClaimSource.spinWheel => AdPlacement.spinWheel,
    RewardClaimSource.scratchCard => AdPlacement.scratchCard,
  };

  @override
  RewardClaimState build() => const RewardClaimState();

  Future<void> watchAdAndCollect() async {
    if (state.isBusy || state.phase == RewardClaimPhase.collected) return;
    final placement = placementFor(reward.source);

    var unit = _watchedOn;
    if (unit == null) {
      state = const RewardClaimState(phase: RewardClaimPhase.showingAd);
      final outcome = await ref
          .read(adServiceProvider)
          .showRewarded(placement: placement, customData: reward.claimId);
      if (!ref.mounted) return;
      switch (outcome) {
        case RewardedAdEarned(unit: final earnedOn):
          unit = _watchedOn = earnedOn;
        case RewardedAdDismissed():
          state = const RewardClaimState(
            message: 'Watch the whole ad to collect your coins.',
          );
          return;
        case RewardedAdUnavailable():
          state = const RewardClaimState(
            message: 'No ad is available right now. Please try again shortly.',
          );
          return;
      }
    }

    state = const RewardClaimState(phase: RewardClaimPhase.collecting);
    try {
      final result = await ref
          .read(completeRewardClaimProvider)
          .call(reward: reward, adUnit: unit, placement: placement);
      if (!ref.mounted) return;
      refreshAfterEarning(ref);
      state = RewardClaimState(
        phase: RewardClaimPhase.collected,
        result: result,
      );
    } on Object catch (error) {
      if (!ref.mounted) return;
      state = RewardClaimState(message: userMessageFor(error), adWatched: true);
    }
  }
}
