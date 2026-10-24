import '../../../../core/utils/json_reader.dart';
import '../../domain/entities/referral.dart';

class InvitedUserModel extends InvitedUser {
  const InvitedUserModel({
    required super.id,
    required super.name,
    required super.joinedAt,
    required super.status,
    required super.coinsEarned,
    super.avatarUrl,
  });

  factory InvitedUserModel.fromJson(Map<String, dynamic> json) =>
      InvitedUserModel(
        id: json.readString('id'),
        name: json.readString('name'),
        avatarUrl: json.readStringOrNull('avatarUrl'),
        joinedAt: json.readDateTime('joinedAt'),
        status: json.readEnum(
          'status',
          ReferralStatus.values,
          ReferralStatus.pending,
        ),
        coinsEarned: json.readInt('coinsEarned'),
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'avatarUrl': avatarUrl,
    'joinedAt': joinedAt.toIso8601String(),
    'status': status.name,
    'coinsEarned': coinsEarned,
  };
}

class ReferralInfoModel extends ReferralInfo {
  const ReferralInfoModel({
    required super.code,
    required super.shareLink,
    required super.shareMessage,
    required super.rewardPerReferral,
    required super.totalInvited,
    required super.successfulReferrals,
    required super.totalEarned,
    required super.pendingCoins,
    required List<InvitedUserModel> super.invitedUsers,
  });

  factory ReferralInfoModel.fromJson(Map<String, dynamic> json) =>
      ReferralInfoModel(
        code: json.readString('code'),
        shareLink: json.readString('shareLink'),
        shareMessage: json.readString('shareMessage'),
        rewardPerReferral: json.readInt('rewardPerReferral'),
        totalInvited: json.readInt('totalInvited'),
        successfulReferrals: json.readInt('successfulReferrals'),
        totalEarned: json.readInt('totalEarned'),
        pendingCoins: json.readInt('pendingCoins'),
        invitedUsers: json.readList('invitedUsers', InvitedUserModel.fromJson),
      );
}
