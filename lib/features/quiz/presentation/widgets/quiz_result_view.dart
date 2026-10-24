import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/coin_icon.dart';
import '../../domain/entities/quiz.dart';

/// Score, coins earned and per-question review after submission.
class QuizResultView extends StatelessWidget {
  const QuizResultView({
    required this.result,
    required this.quiz,
    required this.onDone,
    super.key,
  });

  final QuizResult result;
  final Quiz quiz;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final questions = {for (final q in quiz.questions) q.id: q};
    final percent = (result.score * 100).round();

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.page),
      children: [
        AppCard(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            children: [
              SizedBox.square(
                dimension: 120,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: result.score,
                      strokeWidth: 10,
                      backgroundColor: AppColors.border,
                      color: percent >= 60
                          ? AppColors.success
                          : AppColors.warning,
                    ),
                    Center(
                      child: Text(
                        '$percent%',
                        style: AppTextStyles.headlineMedium,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                percent >= 60 ? 'Great job!' : 'Keep practising!',
                style: AppTextStyles.titleLarge,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${result.correctCount} of ${result.totalQuestions} correct',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              CoinAmountBadge(amount: result.coinsEarned),
            ],
          ),
        ),
        if (result.reviews.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xxl),
          const Text('Review', style: AppTextStyles.titleMedium),
          const SizedBox(height: AppSpacing.md),
          for (final review in result.reviews) ...[
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    review.isCorrect
                        ? Icons.check_circle_rounded
                        : Icons.cancel_rounded,
                    color: review.isCorrect
                        ? AppColors.success
                        : AppColors.error,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          questions[review.questionId]?.text ?? '',
                          style: AppTextStyles.bodyMedium,
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          'Answer: ${review.correctAnswer}',
                          style: AppTextStyles.bodySmall.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ],
        const SizedBox(height: AppSpacing.xl),
        AppButton(label: 'Done', onPressed: onDone),
      ],
    );
  }
}
