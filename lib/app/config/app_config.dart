import 'environment.dart';

/// Application-wide configuration resolved from `--dart-define` values.
abstract final class AppConfig {
  static const String appName = 'Kavodnik';

  static Environment get environment => Environment.current;

  /// When `true` every repository is backed by in-memory mock data sources,
  /// so the app runs without a backend. Switch to the real API with
  /// `--dart-define=USE_MOCK_API=false`.
  static const bool useMockApi = bool.fromEnvironment(
    'USE_MOCK_API',
    defaultValue: true,
  );

  /// OAuth *web* client id of the backend, required on Android to receive a
  /// Google ID token. Provide with `--dart-define=GOOGLE_SERVER_CLIENT_ID=...`.
  static const String googleServerClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
  );

  static bool get isGoogleSignInConfigured => googleServerClientId.isNotEmpty;

  /// Shows a "continue as demo user" option on the login screen. Only ever
  /// available against mock data outside production.
  static bool get enableDemoLogin => useMockApi && !environment.isProduction;

  /// Verbose network logging (never in production).
  static bool get enableNetworkLogs => !environment.isProduction;

  static const String playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.kavodnik.app';
}
