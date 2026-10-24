import '../../../../core/utils/json_reader.dart';
import '../../domain/entities/product.dart';

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.merchantId,
    required super.name,
    required super.price,
    required super.affiliateUrl,
    super.originalPrice,
    super.currencySymbol,
    super.imageUrl,
    super.rating,
    super.rewardText,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
    id: json.readString('id'),
    merchantId: json.readString('merchantId'),
    name: json.readString('name'),
    imageUrl: json.readStringOrNull('imageUrl'),
    price: json.readDouble('price'),
    originalPrice: json['originalPrice'] == null
        ? null
        : json.readDouble('originalPrice'),
    currencySymbol: json.readString('currencySymbol', fallback: '₹'),
    affiliateUrl: json.readString('affiliateUrl'),
    rating: json['rating'] == null ? null : json.readDouble('rating'),
    rewardText: json.readStringOrNull('rewardText'),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'merchantId': merchantId,
    'name': name,
    'imageUrl': imageUrl,
    'price': price,
    'originalPrice': originalPrice,
    'currencySymbol': currencySymbol,
    'affiliateUrl': affiliateUrl,
    'rating': rating,
    'rewardText': rewardText,
  };
}
