import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/core_providers.dart';
import '../../wallet/di/wallet_dependencies.dart';
import '../data/datasources/quiz_mock_data_source.dart';
import '../data/datasources/quiz_remote_data_source.dart';
import '../data/repositories/quiz_repository_impl.dart';
import '../domain/repositories/quiz_repository.dart';
import '../domain/usecases/quiz_usecases.dart';

final quizRemoteDataSourceProvider = Provider<QuizRemoteDataSource>((ref) {
  if (ref.watch(useMockApiProvider)) {
    return QuizMockDataSource(ref.watch(mockWalletLedgerProvider));
  }
  return QuizApiDataSource(ref.watch(apiClientProvider));
});

final quizRepositoryProvider = Provider<QuizRepository>(
  (ref) => QuizRepositoryImpl(ref.watch(quizRemoteDataSourceProvider)),
);

final getQuizCategoriesProvider = Provider(
  (ref) => GetQuizCategories(ref.watch(quizRepositoryProvider)),
);
final getQuizProvider = Provider(
  (ref) => GetQuiz(ref.watch(quizRepositoryProvider)),
);
final submitQuizProvider = Provider(
  (ref) => SubmitQuiz(ref.watch(quizRepositoryProvider)),
);
