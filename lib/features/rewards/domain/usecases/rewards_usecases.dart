import '../../../../core/ads/ad_models.dart';
import '../../../../core/errors/errors.dart';
import '../entities/captcha.dart';
import '../entities/check_in.dart';
import '../entities/reward_claim.dart';
import '../entities/reward_summary.dart';
import '../entities/reward_task.dart';
import '../entities/scratch_card.dart';
import '../entities/spin_wheel.dart';
import '../repositories/rewards_repository.dart';

class GetDailyRewards {
  const GetDailyRewards(this._repository);
  final RewardsRepository _repository;

  Future<List<RewardTask>> call() => _repository.getDailyRewards();
}

class GetRewardSummary {
  const GetRewardSummary(this._repository);
  final RewardsRepository _repository;

  Future<RewardSummary> call() => _repository.getSummary();
}

class GetRewardHistory {
  const GetRewardHistory(this._repository);
  final RewardsRepository _repository;

  Future<List<RewardActivity>> call() => _repository.getHistory();
}

class GetCheckInStatus {
  const GetCheckInStatus(this._repository);
  final RewardsRepository _repository;

  Future<CheckInStatus> call() => _repository.getCheckInStatus();
}

class ClaimCheckIn {
  const ClaimCheckIn(this._repository);
  final RewardsRepository _repository;

  Future<PendingReward> call() => _repository.claimCheckIn();
}

/// Collects a [PendingReward] after its rewarded ad.
///
/// The backend may confirm the ad through the ad network's server-to-server
/// callback, which can arrive a few seconds after the ad closes. Until then
/// it answers `AD_NOT_VERIFIED`, and this use case retries a few times.
class CompleteRewardClaim {
  const CompleteRewardClaim(
    this._repository, {
    this.retryDelays = const [
      Duration(seconds: 2),
      Duration(seconds: 3),
      Duration(seconds: 5),
    ],
  });

  final RewardsRepository _repository;
  final List<Duration> retryDelays;

  static bool isNotVerified(Object error) =>
      error is AppException &&
      error.code?.toLowerCase().replaceAll('_', '') == 'adnotverified';

  Future<ClaimedReward> call({
    required PendingReward reward,
    required AdUnit adUnit,
    required AdPlacement placement,
  }) async {
    for (var attempt = 0; ; attempt++) {
      try {
        return await _repository.completeRewardClaim(
          claimId: reward.claimId,
          adUnit: adUnit,
          placement: placement,
        );
      } on Object catch (error) {
        if (!isNotVerified(error) || attempt >= retryDelays.length) rethrow;
        await Future<void>.delayed(retryDelays[attempt]);
      }
    }
  }
}

class GetSpinWheel {
  const GetSpinWheel(this._repository);
  final RewardsRepository _repository;

  Future<SpinWheelConfig> call() => _repository.getSpinWheel();
}

class SpinWheel {
  const SpinWheel(this._repository);
  final RewardsRepository _repository;

  Future<SpinResult> call() => _repository.spin();
}

class GetScratchCard {
  const GetScratchCard(this._repository);
  final RewardsRepository _repository;

  Future<ScratchCardStatus> call() => _repository.getScratchCard();
}

class RevealScratchCard {
  const RevealScratchCard(this._repository);
  final RewardsRepository _repository;

  Future<ScratchResult> call(String cardId) =>
      _repository.revealScratchCard(cardId);
}

class GetCaptcha {
  const GetCaptcha(this._repository);
  final RewardsRepository _repository;

  Future<CaptchaChallenge> call() => _repository.getCaptcha();
}

class SubmitCaptcha {
  const SubmitCaptcha(this._repository);
  final RewardsRepository _repository;

  Future<CaptchaResult> call({
    required String challengeId,
    required String answer,
  }) {
    final trimmed = answer.trim();
    if (trimmed.isEmpty) {
      throw const ValidationException(
        message: 'Please type the characters you see.',
      );
    }
    return _repository.submitCaptcha(challengeId: challengeId, answer: trimmed);
  }
}
