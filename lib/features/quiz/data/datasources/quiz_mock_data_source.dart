import 'dart:math';

import '../../../../core/errors/errors.dart';
import '../../../../core/mock/mock_latency.dart';
import '../../../wallet/data/datasources/mock_wallet_ledger.dart';
import '../../../wallet/domain/entities/transaction.dart';
import '../../domain/entities/quiz.dart';
import '../models/quiz_models.dart';
import 'quiz_remote_data_source.dart';

/// Simulated quiz backend. The answer key lives here, standing in for the
/// server; the client-facing [QuizModel] never contains answers.
class QuizMockDataSource implements QuizRemoteDataSource {
  QuizMockDataSource(this._ledger, {Random? random})
    : _random = random ?? Random();

  final MockWalletLedger _ledger;
  final Random _random;

  static const _dailyReward = 10;
  static const _mathReward = 5;
  static const _giveAnswerReward = 15;

  /// quizId -> (questionId -> accepted answers). Option answers use ids.
  final Map<String, Map<String, List<String>>> _answerKeys = {};

  /// quizId -> question texts of choices, to reveal the right answer.
  final Map<String, Map<String, String>> _answerLabels = {};
  final Map<String, QuizType> _quizTypes = {};
  final Set<QuizType> _completedToday = {};
  int _sequence = 0;

  @override
  Future<List<QuizCategoryModel>> getCategories() async {
    await MockLatency.simulate();
    return [
      QuizCategoryModel(
        id: 'quiz_daily',
        type: QuizType.daily,
        title: 'Daily Quiz',
        subtitle: 'Test your general knowledge',
        rewardCoins: _dailyReward,
        questionCount: _dailyBank.length,
        isCompleted: _completedToday.contains(QuizType.daily),
      ),
      const QuizCategoryModel(
        id: 'quiz_math',
        type: QuizType.math,
        title: 'Math Quiz',
        subtitle: 'Solve math and win coins',
        rewardCoins: _mathReward,
        questionCount: 5,
      ),
      QuizCategoryModel(
        id: 'quiz_give_answer',
        type: QuizType.giveAnswer,
        title: 'Give Answer',
        subtitle: 'Answer questions and earn coins',
        rewardCoins: _giveAnswerReward,
        questionCount: _giveAnswerBank.length,
        isCompleted: _completedToday.contains(QuizType.giveAnswer),
      ),
    ];
  }

  @override
  Future<QuizModel> getQuiz(QuizType type) async {
    await MockLatency.simulate();
    if (_completedToday.contains(type)) {
      throw const ValidationException(
        message: "You've completed this quiz today. Come back tomorrow!",
        code: 'quiz_completed',
      );
    }
    final quizId = 'quiz_${type.name}_${++_sequence}';
    _quizTypes[quizId] = type;
    return switch (type) {
      QuizType.daily => _buildChoiceQuiz(
        quizId,
        type: type,
        title: 'Daily Quiz',
        bank: _dailyBank,
        reward: _dailyReward,
        seconds: 20,
      ),
      QuizType.math => _buildChoiceQuiz(
        quizId,
        type: type,
        title: 'Math Quiz',
        bank: List.generate(5, (_) => _mathQuestion()),
        reward: _mathReward,
        seconds: 15,
      ),
      QuizType.giveAnswer => _buildTextQuiz(quizId),
    };
  }

  @override
  Future<QuizResultModel> submit({
    required String quizId,
    required List<QuizAnswer> answers,
  }) async {
    await MockLatency.simulate();
    final key = _answerKeys.remove(quizId);
    final labels = _answerLabels.remove(quizId) ?? const {};
    final type = _quizTypes.remove(quizId);
    if (key == null || type == null) {
      throw const ValidationException(
        message: 'This quiz has expired. Please start again.',
        code: 'quiz_expired',
      );
    }

    final reviews = <QuestionReviewModel>[];
    for (final entry in key.entries) {
      final answer = answers
          .where((a) => a.questionId == entry.key)
          .firstOrNull;
      final given = (answer?.optionId ?? answer?.text ?? '')
          .trim()
          .toLowerCase();
      final correct = entry.value.any(
        (accepted) => accepted.toLowerCase() == given,
      );
      reviews.add(
        QuestionReviewModel(
          questionId: entry.key,
          isCorrect: correct,
          correctAnswer: labels[entry.key] ?? entry.value.first,
        ),
      );
    }

    final correctCount = reviews.where((r) => r.isCorrect).length;
    final rewardPerCorrect = switch (type) {
      QuizType.daily => _dailyReward,
      QuizType.math => _mathReward,
      QuizType.giveAnswer => _giveAnswerReward,
    };
    final coins = correctCount * rewardPerCorrect;
    if (coins > 0) {
      _ledger.credit(
        source: TransactionSource.quiz,
        title: switch (type) {
          QuizType.daily => 'Daily Quiz',
          QuizType.math => 'Math Quiz',
          QuizType.giveAnswer => 'Give Answer',
        },
        amount: coins,
        description: '$correctCount of ${reviews.length} correct',
      );
    }
    if (type != QuizType.math) _completedToday.add(type);

    return QuizResultModel(
      correctCount: correctCount,
      totalQuestions: reviews.length,
      coinsEarned: coins,
      reviews: reviews,
    );
  }

  // -------------------------------------------------------------------------
  // Question banks
  // -------------------------------------------------------------------------

  QuizModel _buildChoiceQuiz(
    String quizId, {
    required QuizType type,
    required String title,
    required List<_ChoiceQuestion> bank,
    required int reward,
    required int seconds,
  }) {
    final key = <String, List<String>>{};
    final labels = <String, String>{};
    final questions = <QuizQuestionModel>[];
    for (var i = 0; i < bank.length; i++) {
      final q = bank[i];
      final questionId = '${quizId}_q$i';
      final options = [
        for (var j = 0; j < q.options.length; j++)
          QuizOptionModel(id: '${questionId}_o$j', text: q.options[j]),
      ]..shuffle(_random);
      final correctOption = options.firstWhere(
        (o) => o.text == q.options[q.correctIndex],
      );
      key[questionId] = [correctOption.id];
      labels[questionId] = correctOption.text;
      questions.add(
        QuizQuestionModel(
          id: questionId,
          text: q.text,
          answerType: QuizAnswerType.singleChoice,
          options: options,
        ),
      );
    }
    _answerKeys[quizId] = key;
    _answerLabels[quizId] = labels;
    return QuizModel(
      id: quizId,
      type: type,
      title: title,
      questions: questions,
      rewardPerCorrect: reward,
      secondsPerQuestion: seconds,
    );
  }

  QuizModel _buildTextQuiz(String quizId) {
    final key = <String, List<String>>{};
    final questions = <QuizQuestionModel>[];
    for (var i = 0; i < _giveAnswerBank.length; i++) {
      final q = _giveAnswerBank[i];
      final questionId = '${quizId}_q$i';
      key[questionId] = q.accepted;
      questions.add(
        QuizQuestionModel(
          id: questionId,
          text: q.text,
          answerType: QuizAnswerType.text,
        ),
      );
    }
    _answerKeys[quizId] = key;
    return QuizModel(
      id: quizId,
      type: QuizType.giveAnswer,
      title: 'Give Answer',
      questions: questions,
      rewardPerCorrect: _giveAnswerReward,
    );
  }

  _ChoiceQuestion _mathQuestion() {
    final a = 5 + _random.nextInt(45);
    final b = 2 + _random.nextInt(20);
    final (text, answer) = switch (_random.nextInt(3)) {
      0 => ('$a + $b = ?', a + b),
      1 => ('$a - $b = ?', a - b),
      _ => ('${a % 12 + 2} × ${b % 9 + 2} = ?', (a % 12 + 2) * (b % 9 + 2)),
    };
    final wrong = <int>{};
    while (wrong.length < 3) {
      final candidate = answer + _random.nextInt(11) - 5;
      if (candidate != answer) wrong.add(candidate);
    }
    return _ChoiceQuestion(text, ['$answer', for (final w in wrong) '$w'], 0);
  }

  static const _dailyBank = [
    _ChoiceQuestion('What is the capital of Australia?', [
      'Canberra',
      'Sydney',
      'Melbourne',
      'Perth',
    ], 0),
    _ChoiceQuestion('Which planet is known as the Red Planet?', [
      'Mars',
      'Venus',
      'Jupiter',
      'Mercury',
    ], 0),
    _ChoiceQuestion('How many continents are there on Earth?', [
      '7',
      '5',
      '6',
      '8',
    ], 0),
    _ChoiceQuestion('Which gas do plants absorb from the air?', [
      'Carbon dioxide',
      'Oxygen',
      'Nitrogen',
      'Helium',
    ], 0),
    _ChoiceQuestion('Who wrote "Romeo and Juliet"?', [
      'William Shakespeare',
      'Charles Dickens',
      'Jane Austen',
      'Mark Twain',
    ], 0),
  ];

  static const _giveAnswerBank = [
    _TextQuestion('What is the largest ocean on Earth?', [
      'pacific',
      'pacific ocean',
    ]),
    _TextQuestion('How many days are there in a leap year?', ['366']),
    _TextQuestion('What is the chemical symbol for gold?', ['au']),
  ];
}

class _ChoiceQuestion {
  const _ChoiceQuestion(this.text, this.options, this.correctIndex);

  final String text;
  final List<String> options;
  final int correctIndex;
}

class _TextQuestion {
  const _TextQuestion(this.text, this.accepted);

  final String text;
  final List<String> accepted;
}
