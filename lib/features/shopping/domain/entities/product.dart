import 'package:flutter/foundation.dart';

/// A product sold on a partner platform. Buying goes through [affiliateUrl],
/// so the purchase is attributed to Kavodnik (and to the user, when the
/// backend puts a user sub-id in the link).
@immutable
class Product {
  const Product({
    required this.id,
    required this.merchantId,
    required this.name,
    required this.price,
    required this.affiliateUrl,
    this.originalPrice,
    this.currencySymbol = '₹',
    this.imageUrl,
    this.rating,
    this.rewardText,
  });

  final String id;
  final String merchantId;
  final String name;
  final String? imageUrl;

  /// Selling price.
  final double price;

  /// MRP / list price before discount, if any.
  final double? originalPrice;
  final String currencySymbol;

  /// Where "Buy now" goes. Opened in the platform's app or the browser.
  final String affiliateUrl;

  /// Average rating out of 5, if the platform provides it.
  final double? rating;

  /// Reward hint such as "Earn 60 coins".
  final String? rewardText;

  bool get hasDiscount => originalPrice != null && originalPrice! > price;

  /// Whole-number discount, e.g. 35 for 35% off. 0 when there's none.
  int get discountPercent =>
      hasDiscount ? ((1 - price / originalPrice!) * 100).round() : 0;
}
