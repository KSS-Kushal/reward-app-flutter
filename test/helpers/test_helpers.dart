import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kavodnik/app/theme/app_theme.dart';
import 'package:kavodnik/core/di/core_providers.dart';
import 'package:kavodnik/core/mock/mock_latency.dart';
import 'package:kavodnik/core/storage/local_storage_service.dart';
import 'package:kavodnik/core/storage/secure_storage_service.dart';
import 'package:kavodnik/features/authentication/data/datasources/google_auth_service.dart';
import 'package:kavodnik/features/authentication/di/auth_dependencies.dart';
import 'package:kavodnik/features/authentication/domain/auth_exceptions.dart';
import 'package:kavodnik/features/authentication/domain/entities/google_credential.dart';

/// Removes artificial latency from mock data sources.
void disableMockLatency() => MockLatency.value = Duration.zero;

/// Overrides that replace platform plugins with in-memory fakes, so the
/// whole app (mock backend included) runs inside `flutter test`.
List<Override> testOverrides({
  SecureStorageService? secureStorage,
  GoogleAuthService? googleAuthService,
}) => [
  secureStorageProvider.overrideWithValue(
    secureStorage ?? InMemorySecureStorageService(),
  ),
  localStorageProvider.overrideWithValue(InMemoryLocalStorageService()),
  useMockApiProvider.overrideWithValue(true),
  googleAuthServiceProvider.overrideWithValue(
    googleAuthService ?? FakeGoogleAuthService(),
  ),
];

ProviderContainer createTestContainer({List<Override> overrides = const []}) {
  final container = ProviderContainer(
    overrides: [...testOverrides(), ...overrides],
    retry: (_, _) => null,
  );
  addTearDown(container.dispose);
  return container;
}

/// Wraps [child] in the app theme for widget tests of single components.
Widget themed(Widget child) => MaterialApp(
  theme: AppTheme.light,
  home: Scaffold(body: Center(child: child)),
);

/// Google Sign-In stand-in.
class FakeGoogleAuthService implements GoogleAuthService {
  FakeGoogleAuthService({this.cancel = false, this.idToken = _demoJwt});

  /// JWT whose payload is
  /// `{"sub":"42","name":"Test User","email":"test@example.com"}`.
  static const _demoJwt =
      'eyJhbGciOiJub25lIn0.'
      'eyJzdWIiOiI0MiIsIm5hbWUiOiJUZXN0IFVzZXIiLCJlbWFpbCI6InRlc3RAZXhhbXBsZS5jb20ifQ.'
      'sig';

  final bool cancel;
  final String idToken;
  int signOutCalls = 0;

  @override
  Future<GoogleCredential> signIn() async {
    if (cancel) throw const AuthCancelledException();
    return GoogleCredential(idToken: idToken, email: 'test@example.com');
  }

  @override
  Future<void> signOut() async => signOutCalls++;
}
