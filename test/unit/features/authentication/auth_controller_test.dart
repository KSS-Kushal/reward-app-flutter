import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kavodnik/core/di/core_providers.dart';
import 'package:kavodnik/core/errors/errors.dart';
import 'package:kavodnik/features/authentication/di/auth_dependencies.dart';
import 'package:kavodnik/features/authentication/domain/auth_exceptions.dart';
import 'package:kavodnik/features/authentication/domain/entities/user.dart';
import 'package:kavodnik/features/authentication/domain/repositories/auth_repository.dart';
import 'package:kavodnik/features/authentication/presentation/providers/auth_controller.dart';
import 'package:kavodnik/features/authentication/presentation/providers/auth_state.dart';

import '../../../helpers/test_helpers.dart';

final _user = User(
  id: 'u1',
  name: 'Ritik Sharma',
  email: 'ritik@example.com',
  joinedAt: DateTime(2026),
);

class _FakeAuthRepository implements AuthRepository {
  User? storedUser;
  Object? signInError;
  bool signedOut = false;
  bool cleared = false;

  @override
  Future<User?> restoreSession() async => storedUser;

  @override
  Future<User> signInWithGoogle() async {
    final error = signInError;
    if (error != null) throw error;
    return _user;
  }

  @override
  Future<User> signInAsDemoUser() async => _user;

  @override
  Future<void> signOut() async => signedOut = true;

  @override
  Future<void> clearLocalSession() async => cleared = true;

  @override
  Future<void> cacheUser(User user) async {}
}

void main() {
  late _FakeAuthRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = _FakeAuthRepository();
    container = createTestContainer(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
    );
  });

  Future<AuthState> settle() async {
    await Future<void>.delayed(Duration.zero);
    return container.read(authControllerProvider);
  }

  test('starts in initial state and resolves to unauthenticated', () async {
    expect(container.read(authControllerProvider), isA<AuthInitial>());
    expect(await settle(), isA<AuthUnauthenticated>());
  });

  test('restores an existing session', () async {
    repository.storedUser = _user;
    container.read(authControllerProvider);
    final state = await settle();
    expect(state, isA<AuthAuthenticated>());
    expect(container.read(currentUserProvider), _user);
  });

  test('Google sign-in success authenticates', () async {
    container.read(authControllerProvider);
    await settle();
    await container.read(authControllerProvider.notifier).signInWithGoogle();
    expect(container.read(authControllerProvider), isA<AuthAuthenticated>());
  });

  test('cancelling sign-in returns to unauthenticated without error', () async {
    repository.signInError = const AuthCancelledException();
    container.read(authControllerProvider);
    await settle();
    await container.read(authControllerProvider.notifier).signInWithGoogle();
    expect(container.read(authControllerProvider), isA<AuthUnauthenticated>());
  });

  test('sign-in failure exposes a user-friendly error', () async {
    repository.signInError = const NetworkException();
    container.read(authControllerProvider);
    await settle();
    await container.read(authControllerProvider.notifier).signInWithGoogle();
    final state = container.read(authControllerProvider);
    expect(state, isA<AuthError>());
    expect((state as AuthError).message, const NetworkException().message);
  });

  test('sign-out clears the session', () async {
    repository.storedUser = _user;
    container.read(authControllerProvider);
    await settle();
    await container.read(authControllerProvider.notifier).signOut();
    expect(repository.signedOut, isTrue);
    expect(container.read(authControllerProvider), isA<AuthUnauthenticated>());
  });

  test('a 401 anywhere in the app signs the user out', () async {
    repository.storedUser = _user;
    container.read(authControllerProvider);
    await settle();

    container.read(sessionEventsProvider).notifySessionExpired();
    final state = await settle();

    expect(repository.cleared, isTrue);
    expect(state, isA<AuthUnauthenticated>());
    expect(
      (state as AuthUnauthenticated).message,
      UnauthorizedException.defaultMessage,
    );
  });
}
