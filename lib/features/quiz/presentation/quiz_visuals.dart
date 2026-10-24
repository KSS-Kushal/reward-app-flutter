import 'package:flutter/material.dart';

import '../../../app/router/route_names.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/feature_icon.dart';
import '../domain/entities/quiz.dart';

extension QuizTypeVisual on QuizType {
  FeatureVisual visual({String? imageUrl}) => switch (this) {
    QuizType.daily => FeatureVisual(
      icon: Icons.assignment_rounded,
      color: AppColors.quizPurple,
      imageUrl: imageUrl,
    ),
    QuizType.math => FeatureVisual(
      icon: Icons.calculate_rounded,
      color: AppColors.quizBlue,
      imageUrl: imageUrl,
    ),
    QuizType.giveAnswer => FeatureVisual(
      icon: Icons.psychology_alt_rounded,
      color: AppColors.quizOrange,
      imageUrl: imageUrl,
    ),
  };

  Color get accentColor => switch (this) {
    QuizType.daily => AppColors.quizPurple,
    QuizType.math => AppColors.quizBlue,
    QuizType.giveAnswer => AppColors.quizOrange,
  };

  String get title => switch (this) {
    QuizType.daily => 'Daily Quiz',
    QuizType.math => 'Math Quiz',
    QuizType.giveAnswer => 'Give Answer',
  };

  String get route => switch (this) {
    QuizType.daily => AppRoutes.dailyQuiz,
    QuizType.math => AppRoutes.mathQuiz,
    QuizType.giveAnswer => AppRoutes.giveAnswer,
  };
}
