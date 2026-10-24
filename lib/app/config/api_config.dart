import 'environment.dart';

/// Network configuration. Every value can be overridden at build time:
///
/// ```bash
/// flutter run --dart-define=API_BASE_URL=https://api.example.com
/// ```
abstract final class ApiConfig {
  static const String _baseUrlOverride = String.fromEnvironment('API_BASE_URL');

  /// Base URL of the backend. An explicit `API_BASE_URL` wins; otherwise the
  /// default for the current [Environment] is used.
  static String get baseUrl {
    if (_baseUrlOverride.isNotEmpty) return _baseUrlOverride;
    return switch (Environment.current) {
      Environment.development => 'https://dev-api.kavodnik.com/api/v1',
      Environment.staging => 'https://staging-api.kavodnik.com/api/v1',
      Environment.production => 'https://api.kavodnik.com/api/v1',
    };
  }

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  /// Default page size for paginated endpoints.
  static const int defaultPageSize = 20;
}
