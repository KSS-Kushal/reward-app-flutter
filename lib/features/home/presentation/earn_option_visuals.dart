import 'package:flutter/material.dart';

import '../../../app/router/route_names.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/feature_icon.dart';
import '../domain/entities/earn_option.dart';

extension EarnOptionTypeVisual on EarnOptionType {
  FeatureVisual visual({String? imageUrl}) => switch (this) {
    EarnOptionType.readAndEarn => FeatureVisual(
      icon: Icons.menu_book_rounded,
      color: const Color(0xFF16A34A),
      imageUrl: imageUrl,
    ),
    EarnOptionType.shopAndEarn => FeatureVisual(
      icon: Icons.shopping_bag_rounded,
      color: const Color(0xFFC026D3),
      imageUrl: imageUrl,
    ),
    EarnOptionType.readArticle => FeatureVisual(
      icon: Icons.article_rounded,
      color: AppColors.quizBlue,
      imageUrl: imageUrl,
    ),
  };

  Color get surfaceColor => switch (this) {
    EarnOptionType.readAndEarn => AppColors.readEarnSurface,
    EarnOptionType.shopAndEarn => AppColors.shopEarnSurface,
    EarnOptionType.readArticle => AppColors.articleSurface,
  };

  /// Chevron colour on the white circle.
  Color get accentColor => switch (this) {
    EarnOptionType.readAndEarn => const Color(0xFF16A34A),
    EarnOptionType.shopAndEarn => const Color(0xFFC026D3),
    EarnOptionType.readArticle => AppColors.quizBlue,
  };

  String get route => switch (this) {
    EarnOptionType.readAndEarn => AppRoutes.readAndEarn,
    EarnOptionType.shopAndEarn => AppRoutes.shopAndEarn,
    EarnOptionType.readArticle => AppRoutes.articles,
  };
}
