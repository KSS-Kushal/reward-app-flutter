import '../../../../core/ads/ad_models.dart';
import '../../domain/entities/captcha.dart';
import '../../domain/entities/check_in.dart';
import '../../domain/entities/reward_claim.dart';
import '../../domain/entities/reward_summary.dart';
import '../../domain/entities/reward_task.dart';
import '../../domain/entities/scratch_card.dart';
import '../../domain/entities/spin_wheel.dart';
import '../../domain/repositories/rewards_repository.dart';
import '../datasources/rewards_remote_data_source.dart';

class RewardsRepositoryImpl implements RewardsRepository {
  const RewardsRepositoryImpl(this._remote);

  final RewardsRemoteDataSource _remote;

  @override
  Future<List<RewardTask>> getDailyRewards() => _remote.getDailyRewards();

  @override
  Future<RewardSummary> getSummary() => _remote.getSummary();

  @override
  Future<List<RewardActivity>> getHistory() => _remote.getHistory();

  @override
  Future<CheckInStatus> getCheckInStatus() => _remote.getCheckInStatus();

  @override
  Future<PendingReward> claimCheckIn() => _remote.claimCheckIn();

  @override
  Future<ClaimedReward> completeRewardClaim({
    required String claimId,
    required AdUnit adUnit,
    required AdPlacement placement,
  }) => _remote.completeRewardClaim(
    claimId: claimId,
    adUnit: adUnit,
    placement: placement,
  );

  @override
  Future<SpinWheelConfig> getSpinWheel() => _remote.getSpinWheel();

  @override
  Future<SpinResult> spin() => _remote.spin();

  @override
  Future<ScratchCardStatus> getScratchCard() => _remote.getScratchCard();

  @override
  Future<ScratchResult> revealScratchCard(String cardId) =>
      _remote.revealScratchCard(cardId);

  @override
  Future<CaptchaChallenge> getCaptcha() => _remote.getCaptcha();

  @override
  Future<CaptchaResult> submitCaptcha({
    required String challengeId,
    required String answer,
  }) => _remote.submitCaptcha(challengeId: challengeId, answer: answer);
}
