import '../entities/quiz.dart';
import '../repositories/quiz_repository.dart';

class GetQuizCategories {
  const GetQuizCategories(this._repository);
  final QuizRepository _repository;

  Future<List<QuizCategory>> call() => _repository.getCategories();
}

class GetQuiz {
  const GetQuiz(this._repository);
  final QuizRepository _repository;

  Future<Quiz> call(QuizType type) => _repository.getQuiz(type);
}

class SubmitQuiz {
  const SubmitQuiz(this._repository);
  final QuizRepository _repository;

  /// Unanswered questions (e.g. timed out) are sent as empty answers so the
  /// backend can score the full quiz.
  Future<QuizResult> call({
    required Quiz quiz,
    required Map<String, QuizAnswer> answers,
  }) => _repository.submit(
    quizId: quiz.id,
    answers: [
      for (final question in quiz.questions)
        answers[question.id] ?? QuizAnswer(questionId: question.id),
    ],
  );
}
