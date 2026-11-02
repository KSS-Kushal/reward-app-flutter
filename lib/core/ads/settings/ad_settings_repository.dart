import 'dart:convert';

import '../../storage/local_storage_service.dart';
import '../../storage/storage_keys.dart';
import '../../utils/app_logger.dart';
import 'ad_settings_model.dart';
import 'ad_settings_source.dart';

/// Loads the admin-managed ad settings once per app start.
///
/// Order: fresh from the backend → last cached copy → [fallback]. The
/// cache means a slow or failed request at start-up still shows ads, and
/// admin changes take effect on the next app start.
class AdSettingsRepository {
  const AdSettingsRepository({
    required this._remote,
    required this._storage,
    this.fallback,
    this.timeout = const Duration(seconds: 5),
  });

  static const _tag = 'AdSettings';

  final AdSettingsRemoteSource _remote;
  final LocalStorageService _storage;

  /// Used when neither the backend nor the cache has settings. `null` in
  /// production: no ads until the backend answers once.
  final AdSettingsModel? fallback;
  final Duration timeout;

  Future<AdSettingsModel?> load() async {
    try {
      final settings = await _remote.fetch().timeout(timeout);
      await _storage.setString(
        StorageKeys.adSettings,
        jsonEncode(settings.toJson()),
      );
      AppLogger.info('Loaded version ${settings.version}', tag: _tag);
      return settings;
    } on Object catch (error) {
      AppLogger.warning('Fetch failed, using cache', tag: _tag, error: error);
    }
    final cached = _readCache();
    if (cached != null) return cached;
    AppLogger.warning(
      fallback == null ? 'No settings: ads off' : 'Using defaults',
      tag: _tag,
    );
    return fallback;
  }

  AdSettingsModel? _readCache() {
    final raw = _storage.getString(StorageKeys.adSettings);
    if (raw == null) return null;
    try {
      return AdSettingsModel.fromJson(
        Map<String, dynamic>.from(jsonDecode(raw) as Map),
      );
    } on Object {
      return null;
    }
  }
}
