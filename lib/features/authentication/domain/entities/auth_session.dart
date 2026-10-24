import 'package:flutter/foundation.dart';

import 'user.dart';

/// Result of a successful backend login.
@immutable
class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.user,
    this.refreshToken,
  });

  final String accessToken;
  final String? refreshToken;
  final User user;
}
