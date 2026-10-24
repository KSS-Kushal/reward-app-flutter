import '../entities/captcha.dart';
import '../entities/check_in.dart';
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
  Future<CheckInResult> claimCheckIn();

  Future<SpinWheelConfig> getSpinWheel();
  Future<SpinResult> spin();

  Future<ScratchCardStatus> getScratchCard();
  Future<ScratchResult> revealScratchCard(String cardId);

  Future<CaptchaChallenge> getCaptcha();
  Future<CaptchaResult> submitCaptcha({
    required String challengeId,
    required String answer,
  });
}
