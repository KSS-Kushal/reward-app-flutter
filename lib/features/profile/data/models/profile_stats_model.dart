import '../../../../core/utils/json_reader.dart';
import '../../domain/entities/profile_stats.dart';

class ProfileStatsModel extends ProfileStats {
  const ProfileStatsModel({
    required super.totalEarned,
    required super.currentStreak,
    required super.rank,
    required super.referrals,
  });

  factory ProfileStatsModel.fromJson(Map<String, dynamic> json) =>
      ProfileStatsModel(
        totalEarned: json.readInt('totalEarned'),
        currentStreak: json.readInt('currentStreak'),
        rank: json.readInt('rank'),
        referrals: json.readInt('referrals'),
      );

  Map<String, dynamic> toJson() => {
    'totalEarned': totalEarned,
    'currentStreak': currentStreak,
    'rank': rank,
    'referrals': referrals,
  };
}
