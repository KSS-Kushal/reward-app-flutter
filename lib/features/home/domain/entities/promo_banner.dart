import 'package:flutter/foundation.dart';

/// A home carousel banner. Fully backend-driven: artwork, copy and the tap
/// destination can all change without an app update.
@immutable
class PromoBanner {
  const PromoBanner({
    required this.id,
    required this.title,
    this.subtitle,
    this.imageUrl,
    this.tag,
    this.actionRoute,
    this.actionUrl,
    this.gradientHex = const ['#E3F2FF', '#BFDDFB'],
  });

  final String id;
  final String title;
  final String? subtitle;

  /// Full-bleed artwork; when absent the banner renders its text on
  /// [gradientHex].
  final String? imageUrl;

  /// Corner tag such as "Ad".
  final String? tag;

  /// In-app destination (a route path such as `/spin-wheel`).
  final String? actionRoute;

  /// External destination opened in the browser.
  final String? actionUrl;
  final List<String> gradientHex;
}
