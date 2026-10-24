import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/errors/errors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/async_value_view.dart';
import '../../../../core/widgets/gradient_page_scaffold.dart';
import '../../domain/entities/quiz.dart';
import '../providers/quiz_providers.dart';
import '../quiz_visuals.dart';
import '../widgets/quiz_option_card.dart';
import '../widgets/quiz_result_view.dart';

/// Plays any quiz type (daily, math, give-answer).
class QuizScreen extends ConsumerWidget {
  const QuizScreen({required this.type, super.key});

  final QuizType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = quizSessionProvider(type);
    final session = ref.watch(provider);
    return GradientPageScaffold(
      title: type.title,
      body: AsyncValueView(
        value: session,
        onRetry: () => ref.invalidate(provider),
        data: (data) => switch (data.phase) {
          QuizPhase.finished => QuizResultView(
            result: data.result!,
            quiz: data.quiz,
            onDone: () => Navigator.of(context).maybePop(),
          ),
          _ => _QuizPlayView(type: type, session: data),
        },
      ),
    );
  }
}

class _QuizPlayView extends ConsumerWidget {
  const _QuizPlayView({required this.type, required this.session});

  final QuizType type;
  final QuizSessionState session;

  static const _letters = ['A', 'B', 'C', 'D', 'E', 'F'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(quizSessionProvider(type).notifier);
    final question = session.currentQuestion;
    final submitting = session.phase == QuizPhase.submitting;
    final accent = type.accentColor;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.page),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Question ${session.index + 1} of '
                '${session.quiz.questions.length}',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            if (session.quiz.isTimed) _TimerChip(seconds: session.secondsLeft),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        ClipRRect(
          borderRadius: AppRadius.pillAll,
          child: LinearProgressIndicator(
            value: session.progress,
            minHeight: 6,
            color: accent,
            backgroundColor: AppColors.border,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        AppCard(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Text(question.text, style: AppTextStyles.titleLarge),
        ),
        const SizedBox(height: AppSpacing.xl),
        if (question.answerType == QuizAnswerType.singleChoice)
          for (var i = 0; i < question.options.length; i++) ...[
            QuizOptionCard(
              label: _letters[i % _letters.length],
              text: question.options[i].text,
              accentColor: accent,
              state: session.currentAnswer?.optionId == question.options[i].id
                  ? QuizOptionState.selected
                  : QuizOptionState.idle,
              onTap: submitting
                  ? null
                  : () => controller.selectOption(question.options[i].id),
            ),
            const SizedBox(height: AppSpacing.md),
          ]
        else
          AppTextField(
            // New field per question so the text resets.
            key: ValueKey(question.id),
            label: 'Your answer',
            hint: 'Type your answer',
            textInputAction: TextInputAction.done,
            onChanged: controller.setTextAnswer,
            onSubmitted: (_) {
              if (session.canAdvance) controller.next();
            },
          ),
        if (session.submitError != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            userMessageFor(session.submitError!),
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
          ),
        ],
        const SizedBox(height: AppSpacing.xl),
        AppButton(
          label: session.isLastQuestion ? 'Submit' : 'Next',
          backgroundColor: accent,
          isLoading: submitting,
          onPressed: session.canAdvance || session.submitError != null
              ? controller.next
              : null,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Earn ${session.quiz.rewardPerCorrect} coins for every correct answer',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySmall,
        ),
      ],
    );
  }
}

class _TimerChip extends StatelessWidget {
  const _TimerChip({required this.seconds});

  final int seconds;

  @override
  Widget build(BuildContext context) {
    final urgent = seconds <= 5;
    return Semantics(
      liveRegion: urgent,
      label: '$seconds seconds left',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: (urgent ? AppColors.error : AppColors.primary).withValues(
            alpha: 0.12,
          ),
          borderRadius: AppRadius.pillAll,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.timer_outlined,
              size: AppSizes.iconSm,
              color: urgent ? AppColors.error : AppColors.primary,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              Formatters.countdown(seconds),
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: urgent ? AppColors.error : AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
