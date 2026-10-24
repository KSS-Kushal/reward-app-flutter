import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../authentication/domain/entities/user.dart';
import '../../../authentication/presentation/providers/auth_controller.dart';
import '../../di/profile_dependencies.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/entities/profile_stats.dart';

final profileStatsProvider = FutureProvider.autoDispose<ProfileStats>(
  (ref) => ref.watch(getProfileStatsProvider).call(),
);

final editProfileControllerProvider =
    AsyncNotifierProvider.autoDispose<EditProfileController, User?>(
      EditProfileController.new,
    );

class EditProfileController extends AsyncNotifier<User?> {
  @override
  User? build() => null;

  /// Returns `true` on success; errors are exposed through [state].
  Future<bool> save({required String name, String? phone}) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.read(updateProfileProvider).call(name: name, phone: phone),
    );
    if (!ref.mounted) return false;
    state = result;
    final user = result.value;
    if (user == null) return false;
    await ref.read(authControllerProvider.notifier).updateUser(user);
    return true;
  }
}

final settingsControllerProvider =
    NotifierProvider<SettingsController, AppSettings>(SettingsController.new);

class SettingsController extends Notifier<AppSettings> {
  @override
  AppSettings build() => ref.read(settingsRepositoryProvider).load();

  Future<void> setPushNotifications({required bool enabled}) =>
      _update(state.copyWith(pushNotificationsEnabled: enabled));

  Future<void> setSoundEffects({required bool enabled}) =>
      _update(state.copyWith(soundEffectsEnabled: enabled));

  Future<void> _update(AppSettings settings) async {
    state = settings;
    await ref.read(settingsRepositoryProvider).save(settings);
  }
}
