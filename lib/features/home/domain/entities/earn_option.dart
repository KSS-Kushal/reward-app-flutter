import 'package:flutter/foundation.dart';

enum EarnOptionType { readAndEarn, shopAndEarn, readArticle }

/// Entry of the "Earn More" section. New options can be added by the backend
/// as long as the app knows the [type].
@immutable
class EarnOption {
  const EarnOption({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    this.imageUrl,
  });

  final String id;
  final EarnOptionType type;
  final String title;
  final String subtitle;
  final String? imageUrl;
}
