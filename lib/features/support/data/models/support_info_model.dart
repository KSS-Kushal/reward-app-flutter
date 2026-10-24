import '../../../../core/utils/json_reader.dart';
import '../../domain/entities/support_info.dart';

class FaqModel extends Faq {
  const FaqModel({required super.question, required super.answer});

  factory FaqModel.fromJson(Map<String, dynamic> json) => FaqModel(
    question: json.readString('question'),
    answer: json.readString('answer'),
  );

  Map<String, dynamic> toJson() => {'question': question, 'answer': answer};
}

class SupportInfoModel extends SupportInfo {
  const SupportInfoModel({
    required super.email,
    required super.workingHours,
    required List<FaqModel> super.faqs,
    super.phone,
    super.chatUrl,
  });

  factory SupportInfoModel.fromJson(Map<String, dynamic> json) =>
      SupportInfoModel(
        email: json.readString('email'),
        phone: json.readStringOrNull('phone'),
        chatUrl: json.readStringOrNull('chatUrl'),
        workingHours: json.readString('workingHours'),
        faqs: json.readList('faqs', FaqModel.fromJson),
      );
}
