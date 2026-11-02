/// Every storage key used by the app, in one place to avoid collisions.
abstract final class StorageKeys {
  // Secure storage.
  static const accessToken = 'auth.access_token';
  static const refreshToken = 'auth.refresh_token';
  static const cachedUser = 'auth.cached_user';

  // Shared preferences (non-sensitive).
  static const onboardingCompleted = 'prefs.onboarding_completed';
  static const pushNotificationsEnabled = 'prefs.push_notifications_enabled';
  static const soundEffectsEnabled = 'prefs.sound_effects_enabled';

  // Cached copy of the admin ad settings (`GET /ads/config`).
  static const adSettings = 'cache.ad_settings';
}
