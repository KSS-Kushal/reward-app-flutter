import 'package:flutter_test/flutter_test.dart';
import 'package:kavodnik/core/errors/errors.dart';
import 'package:kavodnik/core/storage/secure_storage_service.dart';
import 'package:kavodnik/core/storage/storage_keys.dart';
import 'package:kavodnik/core/storage/token_storage.dart';
import 'package:kavodnik/features/authentication/data/datasources/auth_local_data_source.dart';
import 'package:kavodnik/features/authentication/data/datasources/auth_mock_data_source.dart';
import 'package:kavodnik/features/authentication/data/datasources/auth_remote_data_source.dart';
import 'package:kavodnik/features/authentication/data/datasources/mock_user_store.dart';
import 'package:kavodnik/features/authentication/data/models/auth_session_model.dart';
import 'package:kavodnik/features/authentication/data/models/user_model.dart';
import 'package:kavodnik/features/authentication/data/repositories/auth_repository_impl.dart';

import '../../../helpers/test_helpers.dart';

class _RejectingRemote implements AuthRemoteDataSource {
  @override
  Future<AuthSessionModel> loginWithGoogle({required String idToken}) =>
      throw const ServerException();

  @override
  Future<UserModel> getCurrentUser() => throw const UnauthorizedException();

  @override
  Future<void> logout() async {}
}

void main() {
  setUpAll(disableMockLatency);

  late InMemorySecureStorageService storage;
  late FakeGoogleAuthService google;
  late AuthLocalDataSource local;

  setUp(() {
    storage = InMemorySecureStorageService();
    google = FakeGoogleAuthService();
    local = AuthLocalDataSource(
      tokenStorage: TokenStorage(storage),
      secureStorage: storage,
    );
  });

  AuthRepositoryImpl repository([AuthRemoteDataSource? remote]) =>
      AuthRepositoryImpl(
        googleAuthService: google,
        remoteDataSource: remote ?? AuthMockDataSource(MockUserStore()),
        localDataSource: local,
      );

  test('Google sign-in stores tokens securely and returns the user', () async {
    final user = await repository().signInWithGoogle();

    expect(user.name, 'Test User');
    expect(user.email, 'test@example.com');
    expect(await storage.read(StorageKeys.accessToken), isNotEmpty);
    expect(await storage.read(StorageKeys.refreshToken), isNotEmpty);
  });

  test('restoreSession returns null without a stored token', () async {
    expect(await repository().restoreSession(), isNull);
  });

  test('restoreSession returns the user for a stored session', () async {
    final repo = repository();
    await repo.signInAsDemoUser();
    final restored = await repo.restoreSession();
    expect(restored?.id, MockUserStore.demoUser.id);
  });

  test('an expired session is cleared on restore', () async {
    await storage.write(StorageKeys.accessToken, 'stale');
    final restored = await repository(_RejectingRemote()).restoreSession();
    expect(restored, isNull);
    expect(await storage.read(StorageKeys.accessToken), isNull);
  });

  test('backend rejection signs out of Google again', () async {
    await expectLater(
      repository(_RejectingRemote()).signInWithGoogle(),
      throwsA(isA<ServerException>()),
    );
    expect(google.signOutCalls, 1);
    expect(await storage.read(StorageKeys.accessToken), isNull);
  });

  test('signOut wipes every session value', () async {
    final repo = repository();
    await repo.signInAsDemoUser();
    await repo.signOut();
    expect(await storage.read(StorageKeys.accessToken), isNull);
    expect(await storage.read(StorageKeys.cachedUser), isNull);
  });
}
