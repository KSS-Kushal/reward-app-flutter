import '../../../authentication/domain/entities/user.dart';
import '../entities/app_settings.dart';
import '../entities/profile_stats.dart';

abstract interface class ProfileRepository {
  Future<ProfileStats> getStats();

  /// Saves editable fields and returns the updated user.
  Future<User> updateProfile({required String name, String? phone});
}

abstract interface class SettingsRepository {
  AppSettings load();
  Future<void> save(AppSettings settings);
}
