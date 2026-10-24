import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/feature_icon.dart';
import '../domain/entities/redeem_option.dart';
import '../domain/entities/transaction.dart';

/// Presentation mapping of wallet enums to icons, colours and labels.
extension TransactionSourceVisual on TransactionSource {
  FeatureVisual get visual => switch (this) {
    TransactionSource.checkIn => const FeatureVisual(
      icon: Icons.event_available_rounded,
      color: AppColors.checkInAction,
    ),
    TransactionSource.spinWheel => const FeatureVisual(
      icon: Icons.casino_rounded,
      color: AppColors.spinAction,
    ),
    TransactionSource.scratchCard => const FeatureVisual(
      icon: Icons.style_rounded,
      color: AppColors.scratchAction,
    ),
    TransactionSource.captcha => const FeatureVisual(
      icon: Icons.verified_user_rounded,
      color: AppColors.captchaAction,
    ),
    TransactionSource.quiz => const FeatureVisual(
      icon: Icons.quiz_rounded,
      color: AppColors.quizPurple,
    ),
    TransactionSource.article => const FeatureVisual(
      icon: Icons.menu_book_rounded,
      color: AppColors.info,
    ),
    TransactionSource.shopping => const FeatureVisual(
      icon: Icons.shopping_bag_rounded,
      color: Color(0xFFD946EF),
    ),
    TransactionSource.referral => const FeatureVisual(
      icon: Icons.group_add_rounded,
      color: AppColors.inviteRing,
    ),
    TransactionSource.redeem => const FeatureVisual(
      icon: Icons.account_balance_rounded,
      color: AppColors.textSecondary,
    ),
    TransactionSource.bonus => const FeatureVisual(
      icon: Icons.celebration_rounded,
      color: AppColors.coin,
    ),
  };
}

extension TransactionStatusVisual on TransactionStatus {
  String get label => switch (this) {
    TransactionStatus.completed => 'Completed',
    TransactionStatus.pending => 'Pending',
    TransactionStatus.failed => 'Failed',
  };

  Color get color => switch (this) {
    TransactionStatus.completed => AppColors.success,
    TransactionStatus.pending => AppColors.warning,
    TransactionStatus.failed => AppColors.error,
  };
}

extension RedeemMethodVisual on RedeemMethod {
  IconData get icon => switch (this) {
    RedeemMethod.upi => Icons.account_balance_rounded,
    RedeemMethod.paytm => Icons.account_balance_wallet_rounded,
    RedeemMethod.amazonPay => Icons.card_giftcard_rounded,
    RedeemMethod.googlePlay => Icons.shop_rounded,
  };
}
