import '../../../../core/utils/json_reader.dart';
import '../../domain/entities/reward_summary.dart';
import '../../domain/entities/reward_task.dart';

class RewardTaskModel extends RewardTask {
  const RewardTaskModel({
    required super.id,
    required super.type,
    required super.title,
    required super.subtitle,
    required super.actionLabel,
    required super.rewardCoins,
    required super.status,
    super.remainingAttempts,
    super.totalAttempts,
    super.imageUrl,
  });

  factory RewardTaskModel.fromJson(Map<String, dynamic> json) =>
      RewardTaskModel(
        id: json.readString('id'),
        type: json.readEnum(
          'type',
          RewardTaskType.values,
          RewardTaskType.dailyCheckIn,
        ),
        title: json.readString('title'),
        subtitle: json.readString('subtitle'),
        actionLabel: json.readString('actionLabel', fallback: 'Start'),
        rewardCoins: json.readInt('rewardCoins'),
        status: json.readEnum(
          'status',
          RewardTaskStatus.values,
          RewardTaskStatus.available,
        ),
        remainingAttempts: json.readIntOrNull('remainingAttempts'),
        totalAttempts: json.readIntOrNull('totalAttempts'),
        imageUrl: json.readStringOrNull('imageUrl'),
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'title': title,
    'subtitle': subtitle,
    'actionLabel': actionLabel,
    'rewardCoins': rewardCoins,
    'status': status.name,
    'remainingAttempts': remainingAttempts,
    'totalAttempts': totalAttempts,
    'imageUrl': imageUrl,
  };
}

class RewardSummaryModel extends RewardSummary {
  const RewardSummaryModel({
    required super.earnedToday,
    required super.totalEarned,
    required super.currentStreak,
    required super.tasksCompletedToday,
    required super.totalTasksToday,
  });

  factory RewardSummaryModel.fromJson(Map<String, dynamic> json) =>
      RewardSummaryModel(
        earnedToday: json.readInt('earnedToday'),
        totalEarned: json.readInt('totalEarned'),
        currentStreak: json.readInt('currentStreak'),
        tasksCompletedToday: json.readInt('tasksCompletedToday'),
        totalTasksToday: json.readInt('totalTasksToday'),
      );

  Map<String, dynamic> toJson() => {
    'earnedToday': earnedToday,
    'totalEarned': totalEarned,
    'currentStreak': currentStreak,
    'tasksCompletedToday': tasksCompletedToday,
    'totalTasksToday': totalTasksToday,
  };
}

class RewardActivityModel extends RewardActivity {
  const RewardActivityModel({
    required super.id,
    required super.title,
    required super.coins,
    required super.earnedAt,
    super.description,
  });

  factory RewardActivityModel.fromJson(Map<String, dynamic> json) =>
      RewardActivityModel(
        id: json.readString('id'),
        title: json.readString('title'),
        description: json.readStringOrNull('description'),
        coins: json.readInt('coins'),
        earnedAt: json.readDateTime('earnedAt'),
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'coins': coins,
    'earnedAt': earnedAt.toIso8601String(),
  };
}
