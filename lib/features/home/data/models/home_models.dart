import '../../../../core/utils/json_reader.dart';
import '../../domain/entities/earn_option.dart';
import '../../domain/entities/promo_banner.dart';

class PromoBannerModel extends PromoBanner {
  const PromoBannerModel({
    required super.id,
    required super.title,
    super.subtitle,
    super.imageUrl,
    super.tag,
    super.actionRoute,
    super.actionUrl,
    super.gradientHex,
  });

  factory PromoBannerModel.fromJson(Map<String, dynamic> json) {
    final gradient = json.readPrimitiveList<String>('gradient');
    return PromoBannerModel(
      id: json.readString('id'),
      title: json.readString('title'),
      subtitle: json.readStringOrNull('subtitle'),
      imageUrl: json.readStringOrNull('imageUrl'),
      tag: json.readStringOrNull('tag'),
      actionRoute: json.readStringOrNull('actionRoute'),
      actionUrl: json.readStringOrNull('actionUrl'),
      gradientHex: gradient.length >= 2
          ? gradient
          : const ['#E3F2FF', '#BFDDFB'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'subtitle': subtitle,
    'imageUrl': imageUrl,
    'tag': tag,
    'actionRoute': actionRoute,
    'actionUrl': actionUrl,
    'gradient': gradientHex,
  };
}

class EarnOptionModel extends EarnOption {
  const EarnOptionModel({
    required super.id,
    required super.type,
    required super.title,
    required super.subtitle,
    super.imageUrl,
  });

  /// Returns `null` for option types this app version does not support, so
  /// older apps simply skip new backend options.
  static EarnOptionModel? tryFromJson(Map<String, dynamic> json) {
    final rawType = json.readString('type').replaceAll(RegExp('[_-]'), '');
    final type = EarnOptionType.values
        .where((t) => t.name.toLowerCase() == rawType.toLowerCase())
        .firstOrNull;
    if (type == null) return null;
    return EarnOptionModel(
      id: json.readString('id'),
      type: type,
      title: json.readString('title'),
      subtitle: json.readString('subtitle'),
      imageUrl: json.readStringOrNull('imageUrl'),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'title': title,
    'subtitle': subtitle,
    'imageUrl': imageUrl,
  };
}
