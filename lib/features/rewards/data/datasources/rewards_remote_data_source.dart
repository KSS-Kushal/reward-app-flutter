import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../models/reward_game_models.dart';
import '../models/reward_task_model.dart';

abstract interface class RewardsRemoteDataSource {
  Future<List<RewardTaskModel>> getDailyRewards();
  Future<RewardSummaryModel> getSummary();
  Future<List<RewardActivityModel>> getHistory();

  Future<CheckInStatusModel> getCheckInStatus();
  Future<CheckInResultModel> claimCheckIn();

  Future<SpinWheelConfigModel> getSpinWheel();
  Future<SpinResultModel> spin();

  Future<ScratchCardStatusModel> getScratchCard();
  Future<ScratchResultModel> revealScratchCard(String cardId);

  Future<CaptchaChallengeModel> getCaptcha();
  Future<CaptchaResultModel> submitCaptcha({
    required String challengeId,
    required String answer,
  });
}

class RewardsApiDataSource implements RewardsRemoteDataSource {
  const RewardsApiDataSource(this._client);

  final ApiClient _client;

  static Map<String, dynamic> _object(Object? data) =>
      ApiResponse.asObject(data);

  @override
  Future<List<RewardTaskModel>> getDailyRewards() => _client.get(
    ApiEndpoints.dailyRewards,
    parser: (data) =>
        ApiResponse.asList(data)
            .map(RewardTaskModel.fromJson)
            .toList(growable: false),
  );

  @override
  Future<RewardSummaryModel> getSummary() => _client.get(
    ApiEndpoints.rewardSummary,
    parser: (data) => RewardSummaryModel.fromJson(_object(data)),
  );

  @override
  Future<List<RewardActivityModel>> getHistory() => _client.get(
    ApiEndpoints.rewardHistory,
    parser: (data) =>
        ApiResponse.asList(data)
            .map(RewardActivityModel.fromJson)
            .toList(growable: false),
  );

  @override
  Future<CheckInStatusModel> getCheckInStatus() => _client.get(
    ApiEndpoints.checkIn,
    parser: (data) => CheckInStatusModel.fromJson(_object(data)),
  );

  @override
  Future<CheckInResultModel> claimCheckIn() => _client.post(
    ApiEndpoints.checkInClaim,
    parser: (data) => CheckInResultModel.fromJson(_object(data)),
  );

  @override
  Future<SpinWheelConfigModel> getSpinWheel() => _client.get(
    ApiEndpoints.spinWheel,
    parser: (data) => SpinWheelConfigModel.fromJson(_object(data)),
  );

  @override
  Future<SpinResultModel> spin() => _client.post(
    ApiEndpoints.spinWheelSpin,
    parser: (data) => SpinResultModel.fromJson(_object(data)),
  );

  @override
  Future<ScratchCardStatusModel> getScratchCard() => _client.get(
    ApiEndpoints.scratchCard,
    parser: (data) => ScratchCardStatusModel.fromJson(_object(data)),
  );

  @override
  Future<ScratchResultModel> revealScratchCard(String cardId) => _client.post(
    ApiEndpoints.scratchCardReveal(cardId),
    parser: (data) => ScratchResultModel.fromJson(_object(data)),
  );

  @override
  Future<CaptchaChallengeModel> getCaptcha() => _client.get(
    ApiEndpoints.captcha,
    parser: (data) => CaptchaChallengeModel.fromJson(_object(data)),
  );

  @override
  Future<CaptchaResultModel> submitCaptcha({
    required String challengeId,
    required String answer,
  }) => _client.post(
    ApiEndpoints.captchaSubmit(challengeId),
    body: {'answer': answer},
    parser: (data) => CaptchaResultModel.fromJson(_object(data)),
  );
}
