import 'package:flutter/foundation.dart';

enum ReferralStatus { pending, completed }

@immutable
class InvitedUser {
  const InvitedUser({
    required this.id,
    required this.name,
    required this.joinedAt,
    required this.status,
    required this.coinsEarned,
    this.avatarUrl,
  });

  final String id;
  final String name;
  final String? avatarUrl;
  final DateTime joinedAt;

  /// `pending` until the friend completes the qualifying action.
  final ReferralStatus status;
  final int coinsEarned;
}

@immutable
class ReferralInfo {
  const ReferralInfo({
    required this.code,
    required this.shareLink,
    required this.shareMessage,
    required this.rewardPerReferral,
    required this.totalInvited,
    required this.successfulReferrals,
    required this.totalEarned,
    required this.pendingCoins,
    required this.invitedUsers,
  });

  final String code;
  final String shareLink;

  /// Pre-written text for the share sheet (from the backend so it can be
  /// localised or A/B tested).
  final String shareMessage;
  final int rewardPerReferral;
  final int totalInvited;
  final int successfulReferrals;
  final int totalEarned;
  final int pendingCoins;
  final List<InvitedUser> invitedUsers;
}
