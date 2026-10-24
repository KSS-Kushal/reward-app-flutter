import 'package:flutter_test/flutter_test.dart';
import 'package:kavodnik/features/quiz/domain/entities/quiz.dart';
import 'package:kavodnik/features/quiz/presentation/providers/quiz_providers.dart';
import 'package:kavodnik/features/wallet/di/wallet_dependencies.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  setUpAll(disableMockLatency);

  test(
    'answers, advances and submits a quiz for server-side scoring',
    () async {
      final container = createTestContainer();
      final provider = quizSessionProvider(QuizType.daily);
      final subscription = container.listen(provider, (_, _) {});
      addTearDown(subscription.close);

      final initial = await container.read(provider.future);
      expect(initial.quiz.questions, isNotEmpty);
      expect(initial.secondsLeft, initial.quiz.secondsPerQuestion);
      expect(initial.canAdvance, isFalse);

      final controller = container.read(provider.notifier);
      final balanceBefore = container.read(mockWalletLedgerProvider).wallet;

      for (var i = 0; i < initial.quiz.questions.length; i++) {
        final session = container.read(provider).requireValue;
        expect(session.index, i);
        controller.selectOption(session.currentQuestion.options.first.id);
        expect(container.read(provider).requireValue.canAdvance, isTrue);
        await controller.next();
      }

      final finished = container.read(provider).requireValue;
      expect(finished.phase, QuizPhase.finished);
      final result = finished.result!;
      expect(result.totalQuestions, initial.quiz.questions.length);
      expect(result.reviews, hasLength(result.totalQuestions));
      expect(
        container.read(mockWalletLedgerProvider).wallet.balance,
        balanceBefore.balance + result.coinsEarned,
      );
    },
  );

  test('text answers are accepted case-insensitively', () async {
    final container = createTestContainer();
    final provider = quizSessionProvider(QuizType.giveAnswer);
    final subscription = container.listen(provider, (_, _) {});
    addTearDown(subscription.close);

    final session = await container.read(provider.future);
    final controller = container.read(provider.notifier);
    const answers = ['PACIFIC Ocean', '366', 'Au'];
    for (var i = 0; i < session.quiz.questions.length; i++) {
      controller.setTextAnswer(answers[i]);
      await controller.next();
    }

    final result = container.read(provider).requireValue.result!;
    expect(result.correctCount, 3);
  });
}
