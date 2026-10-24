import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../../domain/entities/quiz.dart';
import '../models/quiz_models.dart';

abstract interface class QuizRemoteDataSource {
  Future<List<QuizCategoryModel>> getCategories();
  Future<QuizModel> getQuiz(QuizType type);
  Future<QuizResultModel> submit({
    required String quizId,
    required List<QuizAnswer> answers,
  });
}

class QuizApiDataSource implements QuizRemoteDataSource {
  const QuizApiDataSource(this._client);

  final ApiClient _client;

  /// Path segment per quiz type, e.g. `/quiz/give-answer`.
  static String _typePath(QuizType type) => switch (type) {
    QuizType.daily => 'daily',
    QuizType.math => 'math',
    QuizType.giveAnswer => 'give-answer',
  };

  @override
  Future<List<QuizCategoryModel>> getCategories() => _client.get(
    ApiEndpoints.quizCategories,
    parser: (data) =>
        ApiResponse.asList(data)
            .map(QuizCategoryModel.fromJson)
            .toList(growable: false),
  );

  @override
  Future<QuizModel> getQuiz(QuizType type) => _client.get(
    ApiEndpoints.quiz(_typePath(type)),
    parser: (data) => QuizModel.fromJson(ApiResponse.asObject(data)),
  );

  @override
  Future<QuizResultModel> submit({
    required String quizId,
    required List<QuizAnswer> answers,
  }) => _client.post(
    ApiEndpoints.quizSubmit(quizId),
    body: {'answers': answers.map((a) => a.toJson()).toList()},
    parser: (data) => QuizResultModel.fromJson(ApiResponse.asObject(data)),
  );
}
