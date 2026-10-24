import '../../../../core/storage/local_storage_service.dart';
import '../../../../core/storage/storage_keys.dart';
import '../../../authentication/domain/entities/user.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/entities/profile_stats.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl(this._remote);

  final ProfileRemoteDataSource _remote;

  @override
  Future<ProfileStats> getStats() => _remote.getStats();

  @override
  Future<User> updateProfile({required String name, String? phone}) =>
      _remote.updateProfile(name: name, phone: phone);
}

/// Settings live only on the device, in non-sensitive local storage.
class SettingsRepositoryImpl implements SettingsRepository {
  const SettingsRepositoryImpl(this._storage);

  final LocalStorageService _storage;

  @override
  AppSettings load() => AppSettings(
    pushNotificationsEnabled:
        _storage.getBool(StorageKeys.pushNotificationsEnabled) ?? true,
    soundEffectsEnabled:
        _storage.getBool(StorageKeys.soundEffectsEnabled) ?? true,
  );

  @override
  Future<void> save(AppSettings settings) async {
    await _storage.setBool(
      StorageKeys.pushNotificationsEnabled,
      value: settings.pushNotificationsEnabled,
    );
    await _storage.setBool(
      StorageKeys.soundEffectsEnabled,
      value: settings.soundEffectsEnabled,
    );
  }
}
