import 'package:shared_preferences/shared_preferences.dart';

/// Plain key/value storage for non-sensitive preferences and cached values.
///
/// Do not store tokens or personal data here; use [SecureStorageService].
abstract interface class LocalStorageService {
  bool? getBool(String key);
  Future<void> setBool(String key, {required bool value});
  String? getString(String key);
  Future<void> setString(String key, String value);
  Future<void> remove(String key);
}

class SharedPreferencesStorageService implements LocalStorageService {
  const SharedPreferencesStorageService(this._prefs);

  final SharedPreferences _prefs;

  @override
  bool? getBool(String key) => _prefs.getBool(key);

  @override
  Future<void> setBool(String key, {required bool value}) =>
      _prefs.setBool(key, value);

  @override
  String? getString(String key) => _prefs.getString(key);

  @override
  Future<void> setString(String key, String value) =>
      _prefs.setString(key, value);

  @override
  Future<void> remove(String key) => _prefs.remove(key);
}

/// Non-persistent implementation used by tests.
class InMemoryLocalStorageService implements LocalStorageService {
  final Map<String, Object> _values = {};

  @override
  bool? getBool(String key) => _values[key] as bool?;

  @override
  Future<void> setBool(String key, {required bool value}) async =>
      _values[key] = value;

  @override
  String? getString(String key) => _values[key] as String?;

  @override
  Future<void> setString(String key, String value) async =>
      _values[key] = value;

  @override
  Future<void> remove(String key) async => _values.remove(key);
}
