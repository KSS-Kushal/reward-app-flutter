import '../../../../core/utils/json_reader.dart';
import '../../domain/entities/merchant.dart';

class MerchantCategoryModel extends MerchantCategory {
  const MerchantCategoryModel({required super.id, required super.name});

  factory MerchantCategoryModel.fromJson(Map<String, dynamic> json) =>
      MerchantCategoryModel(
        id: json.readString('id'),
        name: json.readString('name'),
      );

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

class OfferModel extends Offer {
  const OfferModel({
    required super.id,
    required super.title,
    required super.description,
    super.couponCode,
    super.expiresAt,
  });

  factory OfferModel.fromJson(Map<String, dynamic> json) => OfferModel(
    id: json.readString('id'),
    title: json.readString('title'),
    description: json.readString('description'),
    couponCode: json.readStringOrNull('couponCode'),
    expiresAt: json.readDateTimeOrNull('expiresAt'),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'couponCode': couponCode,
    'expiresAt': expiresAt?.toIso8601String(),
  };
}

class MerchantModel extends Merchant {
  const MerchantModel({
    required super.id,
    required super.name,
    required MerchantCategoryModel super.category,
    required super.rewardText,
    required super.cashbackPercent,
    required super.description,
    required super.trackingUrl,
    required super.brandColorHex,
    super.logoUrl,
    List<OfferModel> super.offers = const [],
    super.terms = const [],
    super.isFeatured = false,
  });

  factory MerchantModel.fromJson(Map<String, dynamic> json) => MerchantModel(
    id: json.readString('id'),
    name: json.readString('name'),
    category: MerchantCategoryModel.fromJson(json.readMap('category')),
    rewardText: json.readString('rewardText'),
    cashbackPercent: json.readDouble('cashbackPercent'),
    description: json.readString('description'),
    trackingUrl: json.readString('trackingUrl'),
    brandColorHex: json.readString('brandColor', fallback: '#0B8F55'),
    logoUrl: json.readStringOrNull('logoUrl'),
    offers: json.readList('offers', OfferModel.fromJson),
    terms: json.readPrimitiveList<String>('terms'),
    isFeatured: json.readBool('isFeatured'),
  );
}
