import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/core_providers.dart';
import '../../../../core/errors/errors.dart';
import '../../../../core/utils/app_logger.dart';
import '../../di/auth_dependencies.dart';
import '../../domain/auth_exceptions.dart';
import '../../domain/entities/user.dart';
import 'auth_state.dart';

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

/// The signed-in user, or `null`. Widgets that only need the user watch this.
final currentUserProvider = Provider<User?>(
  (ref) => ref.watch(authControllerProvider).user,
);

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    final subscription = ref
        .watch(sessionEventsProvider)
        .onSessionExpired
        .listen((_) => _onSessionExpired());
    ref.onDispose(subscription.cancel);

    unawaited(_restoreSession());
    return const AuthInitial();
  }

  Future<void> _restoreSession() async {
    try {
      final user = await ref.read(restoreSessionProvider).call();
      if (!ref.mounted) return;
      state = user == null
          ? const AuthUnauthenticated()
          : AuthAuthenticated(user);
    } on Object catch (error, stackTrace) {
      AppLogger.error(
        'Session restore failed',
        tag: 'Auth',
        error: error,
        stackTrace: stackTrace,
      );
      if (ref.mounted) state = const AuthUnauthenticated();
    }
  }

  Future<void> signInWithGoogle() =>
      _signIn(() => ref.read(signInWithGoogleProvider).call());

  Future<void> signInAsDemoUser() =>
      _signIn(() => ref.read(signInAsDemoUserProvider).call());

  Future<void> _signIn(Future<User> Function() signIn) async {
    if (state is AuthLoading) return;
    state = const AuthLoading();
    try {
      final user = await signIn();
      state = AuthAuthenticated(user);
    } on AuthCancelledException {
      AppLogger.warning('Sign-in cancelled', tag: 'Auth');
      state = const AuthUnauthenticated(message: 'Sign-in was cancelled.');
    } on Object catch (error, stackTrace) {
      AppLogger.error(
        'Sign-in failed: ${userMessageFor(error)}',
        tag: 'Auth',
        error: error is AppException ? '$error (cause: ${error.cause})' : error,
        stackTrace: stackTrace,
      );
      state = AuthError(userMessageFor(error));
    }
  }

  Future<void> signOut() async {
    state = const AuthLoading();
    try {
      await ref.read(signOutProvider).call();
    } finally {
      state = const AuthUnauthenticated();
    }
  }

  /// Keeps the session's user in sync after a profile edit.
  Future<void> updateUser(User user) async {
    if (state is! AuthAuthenticated) return;
    state = AuthAuthenticated(user);
    await ref.read(authRepositoryProvider).cacheUser(user);
  }

  Future<void> _onSessionExpired() async {
    if (state is! AuthAuthenticated) return;
    await ref.read(authRepositoryProvider).clearLocalSession();
    state = const AuthUnauthenticated(
      message: UnauthorizedException.defaultMessage,
    );
  }
}
