import 'package:flutter/foundation.dart';

/// Device-level preferences (not synced to the backend).
@immutable
class AppSettings {
  const AppSettings({
    this.pushNotificationsEnabled = true,
    this.soundEffectsEnabled = true,
  });

  final bool pushNotificationsEnabled;
  final bool soundEffectsEnabled;

  AppSettings copyWith({
    bool? pushNotificationsEnabled,
    bool? soundEffectsEnabled,
  }) => AppSettings(
    pushNotificationsEnabled:
        pushNotificationsEnabled ?? this.pushNotificationsEnabled,
    soundEffectsEnabled: soundEffectsEnabled ?? this.soundEffectsEnabled,
  );
}
