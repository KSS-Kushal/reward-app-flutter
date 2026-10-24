import '../../../../core/utils/json_reader.dart';
import '../../domain/entities/leaderboard.dart';

class LeaderboardEntryModel extends LeaderboardEntry {
  const LeaderboardEntryModel({
    required super.rank,
    required super.userId,
    required super.name,
    required super.points,
    super.avatarUrl,
    super.isCurrentUser,
  });

  factory LeaderboardEntryModel.fromJson(Map<String, dynamic> json) =>
      LeaderboardEntryModel(
        rank: json.readInt('rank'),
        userId: json.readString('userId'),
        name: json.readString('name'),
        avatarUrl: json.readStringOrNull('avatarUrl'),
        points: json.readInt('points'),
        isCurrentUser: json.readBool('isCurrentUser'),
      );

  Map<String, dynamic> toJson() => {
    'rank': rank,
    'userId': userId,
    'name': name,
    'avatarUrl': avatarUrl,
    'points': points,
    'isCurrentUser': isCurrentUser,
  };
}

class LeaderboardModel extends Leaderboard {
  const LeaderboardModel({
    required super.period,
    required List<LeaderboardEntryModel> super.entries,
    LeaderboardEntryModel? super.currentUser,
  });

  factory LeaderboardModel.fromJson(Map<String, dynamic> json) {
    final me = json.readMap('currentUser');
    return LeaderboardModel(
      period: json.readEnum(
        'period',
        LeaderboardPeriod.values,
        LeaderboardPeriod.weekly,
      ),
      entries: json.readList('entries', LeaderboardEntryModel.fromJson),
      currentUser: me.isEmpty ? null : LeaderboardEntryModel.fromJson(me),
    );
  }
}
