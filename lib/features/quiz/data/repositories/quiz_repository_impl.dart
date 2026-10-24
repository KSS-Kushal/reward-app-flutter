import '../../domain/entities/quiz.dart';
import '../../domain/repositories/quiz_repository.dart';
import '../datasources/quiz_remote_data_source.dart';

class QuizRepositoryImpl implements QuizRepository {
  const QuizRepositoryImpl(this._remote);

  final QuizRemoteDataSource _remote;

  @override
  Future<List<QuizCategory>> getCategories() => _remote.getCategories();

  @override
  Future<Quiz> getQuiz(QuizType type) => _remote.getQuiz(type);

  @override
  Future<QuizResult> submit({
    required String quizId,
    required List<QuizAnswer> answers,
  }) => _remote.submit(quizId: quizId, answers: answers);
}
