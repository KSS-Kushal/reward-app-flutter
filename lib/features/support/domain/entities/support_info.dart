import 'package:flutter/foundation.dart';

@immutable
class Faq {
  const Faq({required this.question, required this.answer});

  final String question;
  final String answer;
}

/// Contact channels and FAQs, served by the backend so they can change
/// without an app release.
@immutable
class SupportInfo {
  const SupportInfo({
    required this.email,
    required this.workingHours,
    required this.faqs,
    this.phone,
    this.chatUrl,
  });

  final String email;
  final String? phone;

  /// Optional live chat / WhatsApp link.
  final String? chatUrl;
  final String workingHours;
  final List<Faq> faqs;
}
