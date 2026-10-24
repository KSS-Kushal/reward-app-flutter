import '../entities/quiz.dart';

abstract interface class QuizRepository {
  Future<List<QuizCategory>> getCategories();

  /// Fetches a playable quiz. Questions never contain answers.
  Future<Quiz> getQuiz(QuizType type);

  /// Submits answers; scoring and rewards are computed by the backend.
  Future<QuizResult> submit({
    required String quizId,
    required List<QuizAnswer> answers,
  });
}
