import 'package:flutter/foundation.dart';

import '../../domain/entities/user.dart';

/// Authentication lifecycle:
/// `initial` (restoring session) -> `unauthenticated` / `authenticated`;
/// sign-in goes through `loading` and may end in `error`.
@immutable
sealed class AuthState {
  const AuthState();

  User? get user => null;
}

/// App start, before the stored session has been checked.
final class AuthInitial extends AuthState {
  const AuthInitial();
}

final class AuthLoading extends AuthState {
  const AuthLoading();
}

final class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.currentUser);

  final User currentUser;

  @override
  User get user => currentUser;
}

final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated({this.message});

  /// Optional notice, e.g. "Your session has expired".
  final String? message;
}

final class AuthError extends AuthState {
  const AuthError(this.message);

  final String message;
}
