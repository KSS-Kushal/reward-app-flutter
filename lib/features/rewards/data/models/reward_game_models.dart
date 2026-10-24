import '../../../../core/utils/json_reader.dart';
import '../../domain/entities/captcha.dart';
import '../../domain/entities/check_in.dart';
import '../../domain/entities/scratch_card.dart';
import '../../domain/entities/spin_wheel.dart';

// ---------------------------------------------------------------------------
// Check-in
// ---------------------------------------------------------------------------

class CheckInDayModel extends CheckInDay {
  const CheckInDayModel({
    required super.day,
    required super.coins,
    required super.state,
  });

  factory CheckInDayModel.fromJson(Map<String, dynamic> json) =>
      CheckInDayModel(
        day: json.readInt('day'),
        coins: json.readInt('coins'),
        state: json.readEnum(
          'state',
          CheckInDayState.values,
          CheckInDayState.upcoming,
        ),
      );

  Map<String, dynamic> toJson() => {
    'day': day,
    'coins': coins,
    'state': state.name,
  };
}

class CheckInStatusModel extends CheckInStatus {
  const CheckInStatusModel({
    required super.currentStreak,
    required super.claimedToday,
    required super.todayReward,
    required List<CheckInDayModel> super.days,
    super.nextCheckInAt,
  });

  factory CheckInStatusModel.fromJson(Map<String, dynamic> json) =>
      CheckInStatusModel(
        currentStreak: json.readInt('currentStreak'),
        claimedToday: json.readBool('claimedToday'),
        todayReward: json.readInt('todayReward'),
        days: json.readList('days', CheckInDayModel.fromJson),
        nextCheckInAt: json.readDateTimeOrNull('nextCheckInAt'),
      );

  Map<String, dynamic> toJson() => {
    'currentStreak': currentStreak,
    'claimedToday': claimedToday,
    'todayReward': todayReward,
    'days': days.cast<CheckInDayModel>().map((d) => d.toJson()).toList(),
    'nextCheckInAt': nextCheckInAt?.toIso8601String(),
  };
}

class CheckInResultModel extends CheckInResult {
  const CheckInResultModel({
    required super.coinsEarned,
    required super.newStreak,
  });

  factory CheckInResultModel.fromJson(Map<String, dynamic> json) =>
      CheckInResultModel(
        coinsEarned: json.readInt('coinsEarned'),
        newStreak: json.readInt('newStreak'),
      );
}

// ---------------------------------------------------------------------------
// Spin wheel
// ---------------------------------------------------------------------------

class SpinSegmentModel extends SpinSegment {
  const SpinSegmentModel({
    required super.id,
    required super.label,
    required super.coins,
    required super.colorHex,
  });

  factory SpinSegmentModel.fromJson(Map<String, dynamic> json) =>
      SpinSegmentModel(
        id: json.readString('id'),
        label: json.readString('label'),
        coins: json.readInt('coins'),
        colorHex: json.readString('color', fallback: '#0B8F55'),
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'coins': coins,
    'color': colorHex,
  };
}

class SpinWheelConfigModel extends SpinWheelConfig {
  const SpinWheelConfigModel({
    required List<SpinSegmentModel> super.segments,
    required super.remainingSpins,
    required super.maxSpinsPerDay,
  });

  factory SpinWheelConfigModel.fromJson(Map<String, dynamic> json) =>
      SpinWheelConfigModel(
        segments: json.readList('segments', SpinSegmentModel.fromJson),
        remainingSpins: json.readInt('remainingSpins'),
        maxSpinsPerDay: json.readInt('maxSpinsPerDay'),
      );
}

class SpinResultModel extends SpinResult {
  const SpinResultModel({
    required super.segmentId,
    required super.coinsWon,
    required super.remainingSpins,
  });

  factory SpinResultModel.fromJson(Map<String, dynamic> json) =>
      SpinResultModel(
        segmentId: json.readString('segmentId'),
        coinsWon: json.readInt('coinsWon'),
        remainingSpins: json.readInt('remainingSpins'),
      );
}

// ---------------------------------------------------------------------------
// Scratch card
// ---------------------------------------------------------------------------

class ScratchCardStatusModel extends ScratchCardStatus {
  const ScratchCardStatusModel({
    required super.remainingCards,
    required super.totalCards,
    super.cardId,
  });

  factory ScratchCardStatusModel.fromJson(Map<String, dynamic> json) =>
      ScratchCardStatusModel(
        cardId: json.readStringOrNull('cardId'),
        remainingCards: json.readInt('remainingCards'),
        totalCards: json.readInt('totalCards'),
      );
}

class ScratchResultModel extends ScratchResult {
  const ScratchResultModel({
    required super.cardId,
    required super.coinsWon,
    required super.remainingCards,
    required super.message,
  });

  factory ScratchResultModel.fromJson(Map<String, dynamic> json) =>
      ScratchResultModel(
        cardId: json.readString('cardId'),
        coinsWon: json.readInt('coinsWon'),
        remainingCards: json.readInt('remainingCards'),
        message: json.readString('message'),
      );
}

// ---------------------------------------------------------------------------
// Captcha
// ---------------------------------------------------------------------------

class CaptchaChallengeModel extends CaptchaChallenge {
  const CaptchaChallengeModel({
    required super.id,
    required super.rewardCoins,
    required super.remainingAttempts,
    required super.totalAttempts,
    super.imageUrl,
    super.previewText,
  });

  factory CaptchaChallengeModel.fromJson(Map<String, dynamic> json) =>
      CaptchaChallengeModel(
        id: json.readString('id'),
        imageUrl: json.readStringOrNull('imageUrl'),
        rewardCoins: json.readInt('rewardCoins'),
        remainingAttempts: json.readInt('remainingAttempts'),
        totalAttempts: json.readInt('totalAttempts'),
      );
}

class CaptchaResultModel extends CaptchaResult {
  const CaptchaResultModel({
    required super.isCorrect,
    required super.coinsEarned,
    required super.remainingAttempts,
    required super.message,
  });

  factory CaptchaResultModel.fromJson(Map<String, dynamic> json) =>
      CaptchaResultModel(
        isCorrect: json.readBool('isCorrect'),
        coinsEarned: json.readInt('coinsEarned'),
        remainingAttempts: json.readInt('remainingAttempts'),
        message: json.readString('message'),
      );
}
