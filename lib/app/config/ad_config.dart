import 'environment.dart';

/// Build-time ad switches. Everything else (ad unit ids, Unity game id,
/// network share, frequency, placements) comes from the backend
/// (`GET /ads/config`), managed in the admin panel.
///
/// The AdMob *app* id is not here either: Android reads it from the
/// manifest, which Gradle fills from `ADMOB_APP_ID` (see
/// `android/app/build.gradle.kts`). It cannot change at runtime.
abstract final class AdConfig {
  /// Master switch, e.g. `ADS_ENABLED=false` for screenshots or QA builds.
  static const bool adsEnabled = bool.fromEnvironment(
    'ADS_ENABLED',
    defaultValue: true,
  );

  /// Outside production, AdMob always serves Google's test units and Unity
  /// runs in test mode, even when the backend sends real ids. This protects
  /// the AdMob account from invalid traffic during development.
  static bool get useTestAds => !Environment.current.isProduction;
}
