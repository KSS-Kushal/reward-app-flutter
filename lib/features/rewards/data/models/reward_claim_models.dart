import '../../../../core/utils/json_reader.dart';
import '../../domain/entities/reward_claim.dart';

class PendingRewardModel extends PendingReward {
  const PendingRewardModel({
    required super.claimId,
    required super.source,
    required super.coins,
    super.expiresAt,
  });

  factory PendingRewardModel.fromJson(Map<String, dynamic> json) =>
      PendingRewardModel(
        claimId: json.readString('claimId'),
        source: json.readEnum(
          'source',
          RewardClaimSource.values,
          RewardClaimSource.checkIn,
        ),
        coins: json.readInt('coins'),
        expiresAt: json.readDateTimeOrNull('expiresAt'),
      );

  /// Parses an optional nested `pendingReward` object.
  static PendingRewardModel? maybe(Object? json) => json is Map
      ? PendingRewardModel.fromJson(Map<String, dynamic>.from(json))
      : null;

  Map<String, dynamic> toJson() => {
    'claimId': claimId,
    'source': source.name,
    'coins': coins,
    'expiresAt': expiresAt?.toIso8601String(),
  };
}

class ClaimedRewardModel extends ClaimedReward {
  const ClaimedRewardModel({
    required super.claimId,
    required super.source,
    required super.coinsEarned,
    required super.message,
    super.newStreak,
  });

  factory ClaimedRewardModel.fromJson(Map<String, dynamic> json) =>
      ClaimedRewardModel(
        claimId: json.readString('claimId'),
        source: json.readEnum(
          'source',
          RewardClaimSource.values,
          RewardClaimSource.checkIn,
        ),
        coinsEarned: json.readInt('coinsEarned'),
        message: json.readString('message', fallback: 'Coins added!'),
        newStreak: json.readIntOrNull('newStreak'),
      );
}
