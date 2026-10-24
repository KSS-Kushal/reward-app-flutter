/// Lenient, type-safe accessors for decoded JSON maps.
///
/// Backends frequently send numbers as strings or omit optional fields; these
/// helpers keep model parsing short while staying strict about types.
extension JsonReader on Map<String, dynamic> {
  String readString(String key, {String fallback = ''}) {
    final value = this[key];
    if (value == null) return fallback;
    return value.toString();
  }

  String? readStringOrNull(String key) {
    final value = this[key];
    if (value == null) return null;
    final text = value.toString();
    return text.isEmpty ? null : text;
  }

  int readInt(String key, {int fallback = 0}) {
    final value = this[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  int? readIntOrNull(String key) => this[key] == null ? null : readInt(key);

  double readDouble(String key, {double fallback = 0}) {
    final value = this[key];
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? fallback;
    return fallback;
  }

  bool readBool(String key, {bool fallback = false}) {
    final value = this[key];
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return fallback;
  }

  DateTime readDateTime(String key, {DateTime? fallback}) =>
      readDateTimeOrNull(key) ??
      fallback ??
      DateTime.fromMillisecondsSinceEpoch(0);

  DateTime? readDateTimeOrNull(String key) {
    final value = this[key];
    if (value is String) return DateTime.tryParse(value);
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return null;
  }

  Map<String, dynamic> readMap(String key) {
    final value = this[key];
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  List<T> readList<T>(
    String key,
    T Function(Map<String, dynamic> json) fromJson,
  ) {
    final value = this[key];
    if (value is! List) return <T>[];
    return value
        .whereType<Map<dynamic, dynamic>>()
        .map((item) => fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);
  }

  List<T> readPrimitiveList<T>(String key) {
    final value = this[key];
    if (value is! List) return <T>[];
    return value.whereType<T>().toList(growable: false);
  }

  /// Matches enum values case-insensitively, ignoring `_` and `-`, so
  /// `"daily_check_in"`, `"dailyCheckIn"` and `"DAILY-CHECK-IN"` all resolve.
  T readEnum<T extends Enum>(String key, List<T> values, T fallback) {
    final value = this[key];
    if (value is! String) return fallback;
    final normalized = value.replaceAll(RegExp('[_-]'), '').toLowerCase();
    for (final candidate in values) {
      if (candidate.name.toLowerCase() == normalized) return candidate;
    }
    return fallback;
  }
}
