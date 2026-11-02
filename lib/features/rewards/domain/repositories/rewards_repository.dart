import '../../../../core/ads/ad_models.dart';
import '../entities/captcha.dart';
import '../entities/check_in.dart';
import '../entities/reward_claim.dart';
import '../entities/reward_summary.dart';
import '../entities/reward_task.dart';
import '../entities/scratch_card.dart';
import '../entities/spin_wheel.dart';

/// Every reward outcome (coins won, eligibility, attempts) is decided by the
/// backend. The client only requests actions and renders the results.
abstract interface class RewardsRepository {
  Future<List<RewardTask>> getDailyRewards();
  Future<RewardSummary> getSummary();
  Future<List<RewardActivity>> getHistory();

  Future<CheckInStatus> getCheckInStatus();

  /// Starts today's check-in. The check-in completes (and the coins are
  /// credited) only through [completeRewardClaim] after a rewarded ad.
  Future<PendingReward> claimCheckIn();

  Future<SpinWheelConfig> getSpinWheel();
  Future<SpinResult> spin();

  Future<ScratchCardStatus> getScratchCard();
  Future<ScratchResult> revealScratchCard(String cardId);

  /// Credits a [PendingReward] after its rewarded ad was watched on [adUnit].
  Future<ClaimedReward> completeRewardClaim({
    required String claimId,
    required AdUnit adUnit,
    required AdPlacement placement,
  });

  Future<CaptchaChallenge> getCaptcha();
  Future<CaptchaResult> submitCaptcha({
    required String challengeId,
    required String answer,
  });
}
