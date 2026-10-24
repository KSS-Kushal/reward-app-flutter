import 'package:flutter/foundation.dart';

@immutable
class MerchantCategory {
  const MerchantCategory({required this.id, required this.name});

  final String id;
  final String name;
}

@immutable
class Offer {
  const Offer({
    required this.id,
    required this.title,
    required this.description,
    this.couponCode,
    this.expiresAt,
  });

  final String id;
  final String title;
  final String description;
  final String? couponCode;
  final DateTime? expiresAt;
}

/// A partner store. Purchases made through [trackingUrl] earn cashback,
/// which the backend credits after the store confirms the order.
@immutable
class Merchant {
  const Merchant({
    required this.id,
    required this.name,
    required this.category,
    required this.rewardText,
    required this.cashbackPercent,
    required this.description,
    required this.trackingUrl,
    required this.brandColorHex,
    this.logoUrl,
    this.offers = const [],
    this.terms = const [],
    this.isFeatured = false,
  });

  final String id;
  final String name;
  final MerchantCategory category;

  /// Display text such as "Up to 6% cashback".
  final String rewardText;
  final double cashbackPercent;
  final String description;
  final String trackingUrl;
  final String? logoUrl;

  /// Brand colour for the logo placeholder (`#RRGGBB`).
  final String brandColorHex;
  final List<Offer> offers;
  final List<String> terms;
  final bool isFeatured;
}
