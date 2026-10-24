import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/app_logger.dart';
import '../../../rewards/presentation/providers/rewards_providers.dart';
import '../../di/quiz_dependencies.dart';
import '../../domain/entities/quiz.dart';

final quizCategoriesProvider = FutureProvider.autoDispose<List<QuizCategory>>(
  (ref) => ref.watch(getQuizCategoriesProvider).call(),
);

enum QuizPhase { answering, submitting, finished }

@immutable
class QuizSessionState {
  const QuizSessionState({
    required this.quiz,
    this.index = 0,
    this.answers = const {},
    this.secondsLeft = 0,
    this.phase = QuizPhase.answering,
    this.result,
    this.submitError,
  });

  final Quiz quiz;
  final int index;
  final Map<String, QuizAnswer> answers;
  final int secondsLeft;
  final QuizPhase phase;
  final QuizResult? result;
  final Object? submitError;

  QuizQuestion get currentQuestion => quiz.questions[index];
  QuizAnswer? get currentAnswer => answers[currentQuestion.id];
  bool get isLastQuestion => index == quiz.questions.length - 1;
  bool get canAdvance => !(currentAnswer?.isEmpty ?? true);
  double get progress => (index + 1) / quiz.questions.length;

  QuizSessionState copyWith({
    int? index,
    Map<String, QuizAnswer>? answers,
    int? secondsLeft,
    QuizPhase? phase,
    QuizResult? result,
    Object? submitError,
  }) => QuizSessionState(
    quiz: quiz,
    index: index ?? this.index,
    answers: answers ?? this.answers,
    secondsLeft: secondsLeft ?? this.secondsLeft,
    phase: phase ?? this.phase,
    result: result ?? this.result,
    submitError: submitError,
  );
}

final quizSessionProvider = AsyncNotifierProvider.autoDispose
    .family<QuizSessionController, QuizSessionState, QuizType>(
      QuizSessionController.new,
    );

/// Drives one quiz attempt: navigation, per-question timer and submission.
/// Scoring happens on the backend.
class QuizSessionController extends AsyncNotifier<QuizSessionState> {
  QuizSessionController(this.type);

  final QuizType type;
  Timer? _timer;

  @override
  Future<QuizSessionState> build() async {
    ref.onDispose(() => _timer?.cancel());
    final quiz = await ref.read(getQuizProvider).call(type);
    final initial = QuizSessionState(
      quiz: quiz,
      secondsLeft: quiz.secondsPerQuestion,
    );
    _startTimer(quiz);
    return initial;
  }

  QuizSessionState? get _session => state.value;

  void selectOption(String optionId) => _answer(optionId: optionId);

  void setTextAnswer(String text) => _answer(text: text);

  void _answer({String? optionId, String? text}) {
    final session = _session;
    if (session == null || session.phase != QuizPhase.answering) return;
    final questionId = session.currentQuestion.id;
    state = AsyncData(
      session.copyWith(
        answers: {
          ...session.answers,
          questionId: QuizAnswer(
            questionId: questionId,
            optionId: optionId,
            text: text,
          ),
        },
      ),
    );
  }

  /// Moves to the next question, or submits after the last one.
  Future<void> next() async {
    final session = _session;
    if (session == null || session.phase != QuizPhase.answering) return;
    if (session.isLastQuestion) return submit();
    state = AsyncData(
      session.copyWith(
        index: session.index + 1,
        secondsLeft: session.quiz.secondsPerQuestion,
      ),
    );
  }

  Future<void> submit() async {
    final session = _session;
    if (session == null || session.phase == QuizPhase.submitting) return;
    _timer?.cancel();
    state = AsyncData(session.copyWith(phase: QuizPhase.submitting));
    try {
      final result = await ref
          .read(submitQuizProvider)
          .call(quiz: session.quiz, answers: session.answers);
      if (!ref.mounted) return;
      state = AsyncData(
        session.copyWith(phase: QuizPhase.finished, result: result),
      );
      refreshAfterEarning(ref);
      ref.invalidate(quizCategoriesProvider);
    } on Object catch (error) {
      AppLogger.warning('Quiz submission failed', error: error);
      if (!ref.mounted) return;
      // Stay on the last question so the user can retry submitting.
      state = AsyncData(
        session.copyWith(phase: QuizPhase.answering, submitError: error),
      );
    }
  }

  void _startTimer(Quiz quiz) {
    if (!quiz.isTimed) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    final session = _session;
    if (session == null || session.phase != QuizPhase.answering) return;
    if (session.secondsLeft <= 1) {
      // Time's up: the question counts as unanswered.
      unawaited(next());
      return;
    }
    state = AsyncData(session.copyWith(secondsLeft: session.secondsLeft - 1));
  }
}
