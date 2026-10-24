import 'package:flutter/foundation.dart';

enum QuizType { daily, math, giveAnswer }

enum QuizAnswerType { singleChoice, text }

/// Entry in the home "Quiz Zone".
@immutable
class QuizCategory {
  const QuizCategory({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.rewardCoins,
    required this.questionCount,
    this.isCompleted = false,
    this.imageUrl,
  });

  final String id;
  final QuizType type;
  final String title;
  final String subtitle;

  /// Coins per correct answer.
  final int rewardCoins;
  final int questionCount;
  final bool isCompleted;
  final String? imageUrl;
}

@immutable
class QuizOption {
  const QuizOption({required this.id, required this.text});

  final String id;
  final String text;
}

/// A question as delivered to the client: never includes the answer.
@immutable
class QuizQuestion {
  const QuizQuestion({
    required this.id,
    required this.text,
    required this.answerType,
    this.options = const [],
    this.imageUrl,
  });

  final String id;
  final String text;
  final QuizAnswerType answerType;
  final List<QuizOption> options;
  final String? imageUrl;
}

@immutable
class Quiz {
  const Quiz({
    required this.id,
    required this.type,
    required this.title,
    required this.questions,
    required this.rewardPerCorrect,
    this.secondsPerQuestion = 0,
  });

  final String id;
  final QuizType type;
  final String title;
  final List<QuizQuestion> questions;
  final int rewardPerCorrect;

  /// 0 means untimed.
  final int secondsPerQuestion;

  bool get isTimed => secondsPerQuestion > 0;
}

/// The user's answer to one question.
@immutable
class QuizAnswer {
  const QuizAnswer({required this.questionId, this.optionId, this.text});

  final String questionId;
  final String? optionId;
  final String? text;

  bool get isEmpty =>
      optionId == null && (text == null || text!.trim().isEmpty);
}

@immutable
class QuestionReview {
  const QuestionReview({
    required this.questionId,
    required this.isCorrect,
    required this.correctAnswer,
  });

  final String questionId;
  final bool isCorrect;

  /// Revealed by the backend only after submission.
  final String correctAnswer;
}

@immutable
class QuizResult {
  const QuizResult({
    required this.correctCount,
    required this.totalQuestions,
    required this.coinsEarned,
    this.reviews = const [],
  });

  final int correctCount;
  final int totalQuestions;
  final int coinsEarned;
  final List<QuestionReview> reviews;

  double get score => totalQuestions == 0 ? 0 : correctCount / totalQuestions;
}
