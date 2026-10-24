import '../../../../core/utils/json_reader.dart';
import '../../domain/entities/quiz.dart';

class QuizCategoryModel extends QuizCategory {
  const QuizCategoryModel({
    required super.id,
    required super.type,
    required super.title,
    required super.subtitle,
    required super.rewardCoins,
    required super.questionCount,
    super.isCompleted,
    super.imageUrl,
  });

  factory QuizCategoryModel.fromJson(Map<String, dynamic> json) =>
      QuizCategoryModel(
        id: json.readString('id'),
        type: json.readEnum('type', QuizType.values, QuizType.daily),
        title: json.readString('title'),
        subtitle: json.readString('subtitle'),
        rewardCoins: json.readInt('rewardCoins'),
        questionCount: json.readInt('questionCount'),
        isCompleted: json.readBool('isCompleted'),
        imageUrl: json.readStringOrNull('imageUrl'),
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'title': title,
    'subtitle': subtitle,
    'rewardCoins': rewardCoins,
    'questionCount': questionCount,
    'isCompleted': isCompleted,
    'imageUrl': imageUrl,
  };
}

class QuizOptionModel extends QuizOption {
  const QuizOptionModel({required super.id, required super.text});

  factory QuizOptionModel.fromJson(Map<String, dynamic> json) =>
      QuizOptionModel(id: json.readString('id'), text: json.readString('text'));

  Map<String, dynamic> toJson() => {'id': id, 'text': text};
}

class QuizQuestionModel extends QuizQuestion {
  const QuizQuestionModel({
    required super.id,
    required super.text,
    required super.answerType,
    List<QuizOptionModel> super.options = const [],
    super.imageUrl,
  });

  factory QuizQuestionModel.fromJson(Map<String, dynamic> json) =>
      QuizQuestionModel(
        id: json.readString('id'),
        text: json.readString('text'),
        answerType: json.readEnum(
          'answerType',
          QuizAnswerType.values,
          QuizAnswerType.singleChoice,
        ),
        options: json.readList('options', QuizOptionModel.fromJson),
        imageUrl: json.readStringOrNull('imageUrl'),
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'answerType': answerType.name,
    'options': options
        .map((o) => QuizOptionModel(id: o.id, text: o.text).toJson())
        .toList(),
    'imageUrl': imageUrl,
  };
}

class QuizModel extends Quiz {
  const QuizModel({
    required super.id,
    required super.type,
    required super.title,
    required List<QuizQuestionModel> super.questions,
    required super.rewardPerCorrect,
    super.secondsPerQuestion,
  });

  factory QuizModel.fromJson(Map<String, dynamic> json) => QuizModel(
    id: json.readString('id'),
    type: json.readEnum('type', QuizType.values, QuizType.daily),
    title: json.readString('title'),
    questions: json.readList('questions', QuizQuestionModel.fromJson),
    rewardPerCorrect: json.readInt('rewardPerCorrect'),
    secondsPerQuestion: json.readInt('secondsPerQuestion'),
  );
}

/// Serialises a user answer for submission.
extension QuizAnswerJson on QuizAnswer {
  Map<String, dynamic> toJson() => {
    'questionId': questionId,
    'optionId': ?optionId,
    'text': ?text,
  };
}

class QuestionReviewModel extends QuestionReview {
  const QuestionReviewModel({
    required super.questionId,
    required super.isCorrect,
    required super.correctAnswer,
  });

  factory QuestionReviewModel.fromJson(Map<String, dynamic> json) =>
      QuestionReviewModel(
        questionId: json.readString('questionId'),
        isCorrect: json.readBool('isCorrect'),
        correctAnswer: json.readString('correctAnswer'),
      );
}

class QuizResultModel extends QuizResult {
  const QuizResultModel({
    required super.correctCount,
    required super.totalQuestions,
    required super.coinsEarned,
    List<QuestionReviewModel> super.reviews = const [],
  });

  factory QuizResultModel.fromJson(Map<String, dynamic> json) =>
      QuizResultModel(
        correctCount: json.readInt('correctCount'),
        totalQuestions: json.readInt('totalQuestions'),
        coinsEarned: json.readInt('coinsEarned'),
        reviews: json.readList('reviews', QuestionReviewModel.fromJson),
      );
}
