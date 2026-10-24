import '../../../../core/errors/errors.dart';
import '../entities/captcha.dart';
import '../entities/check_in.dart';
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

  Future<CheckInResult> call() => _repository.claimCheckIn();
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
