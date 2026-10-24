import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/config/app_config.dart';
import '../network/api_client.dart';
import '../network/interceptors/auth_interceptor.dart';
import '../network/interceptors/logging_interceptor.dart';
import '../network/session_events.dart';
import '../storage/local_storage_service.dart';
import '../storage/secure_storage_service.dart';
import '../storage/token_storage.dart';

/// Infrastructure dependencies shared by every feature.
///
/// Feature data sources depend on these providers; widgets never do.

/// Must be overridden in `main()` with an initialised instance.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in main()',
  ),
);

final localStorageProvider = Provider<LocalStorageService>(
  (ref) =>
      SharedPreferencesStorageService(ref.watch(sharedPreferencesProvider)),
);

final secureStorageProvider = Provider<SecureStorageService>(
  (ref) => FlutterSecureStorageService(),
);

final tokenStorageProvider = Provider<TokenStorage>(
  (ref) => TokenStorage(ref.watch(secureStorageProvider)),
);

final sessionEventsProvider = Provider<SessionEvents>((ref) {
  final events = SessionEvents();
  ref.onDispose(events.dispose);
  return events;
});

final apiClientProvider = Provider<ApiClient>(
  (ref) => ApiClient.create(
    interceptors: [
      AuthInterceptor(
        tokenStorage: ref.watch(tokenStorageProvider),
        sessionEvents: ref.watch(sessionEventsProvider),
      ),
      if (AppConfig.enableNetworkLogs) LoggingInterceptor(),
    ],
  ),
);

/// Whether repositories use mock data sources. Overridable in tests.
final useMockApiProvider = Provider<bool>((ref) => AppConfig.useMockApi);
