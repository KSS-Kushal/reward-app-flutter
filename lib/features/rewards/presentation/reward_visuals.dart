import 'package:flutter/material.dart';

import '../../../app/router/route_names.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/feature_icon.dart';
import '../domain/entities/reward_task.dart';

/// Presentation mapping (icon, colours, destination) of each reward type.
/// Kept out of the domain so the backend only sends the `type`.
extension RewardTaskTypeVisual on RewardTaskType {
  FeatureVisual visual({String? imageUrl}) => switch (this) {
    RewardTaskType.dailyCheckIn => FeatureVisual(
      icon: Icons.event_available_rounded,
      color: AppColors.checkInAction,
      imageUrl: imageUrl,
    ),
    RewardTaskType.spinWheel => FeatureVisual(
      icon: Icons.casino_rounded,
      color: AppColors.spinAction,
      imageUrl: imageUrl,
    ),
    RewardTaskType.scratchCard => FeatureVisual(
      icon: Icons.style_rounded,
      color: AppColors.scratchAction,
      imageUrl: imageUrl,
    ),
    RewardTaskType.captcha => FeatureVisual(
      icon: Icons.verified_user_rounded,
      color: AppColors.captchaAction,
      imageUrl: imageUrl,
    ),
  };

  Color get surfaceColor => switch (this) {
    RewardTaskType.dailyCheckIn => AppColors.checkInSurface,
    RewardTaskType.spinWheel => AppColors.spinSurface,
    RewardTaskType.scratchCard => AppColors.scratchSurface,
    RewardTaskType.captcha => AppColors.captchaSurface,
  };

  Color get actionColor => switch (this) {
    RewardTaskType.dailyCheckIn => AppColors.checkInAction,
    RewardTaskType.spinWheel => AppColors.spinAction,
    RewardTaskType.scratchCard => AppColors.scratchAction,
    RewardTaskType.captcha => AppColors.captchaAction,
  };

  String get route => switch (this) {
    RewardTaskType.dailyCheckIn => AppRoutes.dailyCheckIn,
    RewardTaskType.spinWheel => AppRoutes.spinWheel,
    RewardTaskType.scratchCard => AppRoutes.scratchCard,
    RewardTaskType.captcha => AppRoutes.captcha,
  };
}
