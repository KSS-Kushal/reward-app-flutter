import 'package:flutter/painting.dart';

/// Parses `#RRGGBB` / `#AARRGGBB` colours delivered by the backend.
Color colorFromHex(String hex, {Color fallback = const Color(0xFF0B8F55)}) {
  var value = hex.replaceFirst('#', '').trim();
  if (value.length == 6) value = 'FF$value';
  final parsed = int.tryParse(value, radix: 16);
  return parsed == null || value.length != 8 ? fallback : Color(parsed);
}
