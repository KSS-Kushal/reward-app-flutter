import 'dart:convert';

import '../../../../core/errors/errors.dart';
import '../../../../core/mock/mock_latency.dart';
import '../../../../core/utils/json_reader.dart';
import '../models/auth_session_model.dart';
import '../models/user_model.dart';
import 'auth_remote_data_source.dart';
import 'mock_user_store.dart';

/// Simulates the backend auth endpoints.
///
/// A real Google ID token is decoded (not verified; that is the backend's
/// job) so the mock session shows the actual Google name, email and photo.
class AuthMockDataSource implements AuthRemoteDataSource {
  AuthMockDataSource(this._store, {this.persistedUser});

  /// Pseudo token accepted by the mock backend for demo sign-in.
  static const demoIdToken = 'mock-demo-id-token';

  final MockUserStore _store;

  /// Emulates server-side persistence across app restarts: the mock backend
  /// "remembers" the last user that signed in on this device.
  final Future<UserModel?> Function()? persistedUser;

  @override
  Future<AuthSessionModel> loginWithGoogle({required String idToken}) async {
    await MockLatency.simulate();
    final user = idToken == demoIdToken
        ? MockUserStore.demoUser
        : _userFromIdToken(idToken);
    _store.currentUser = user;
    final issuedAt = DateTime.now().millisecondsSinceEpoch;
    return AuthSessionModel(
      accessToken: 'mock-access-${user.id}-$issuedAt',
      refreshToken: 'mock-refresh-${user.id}-$issuedAt',
      user: user,
    );
  }

  @override
  Future<UserModel> getCurrentUser() async {
    await MockLatency.simulate();
    return _store.currentUser ??=
        await persistedUser?.call() ?? MockUserStore.demoUser;
  }

  @override
  Future<void> logout() async {
    await MockLatency.simulate();
    _store.currentUser = null;
  }

  UserModel _userFromIdToken(String idToken) {
    final claims = _decodeJwtPayload(idToken);
    if (claims == null) {
      throw const UnauthorizedException(message: 'Invalid Google token.');
    }
    final demo = MockUserStore.demoUser;
    return UserModel(
      id: 'google_${claims.readString('sub', fallback: demo.id)}',
      name: claims.readString('name', fallback: demo.name),
      email: claims.readString('email', fallback: demo.email),
      avatarUrl: claims.readStringOrNull('picture') ?? demo.avatarUrl,
      referralCode: demo.referralCode,
      joinedAt: DateTime.now(),
    );
  }

  Map<String, dynamic>? _decodeJwtPayload(String token) {
    final parts = token.split('.');
    if (parts.length != 3) return null;
    try {
      final payload = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      );
      final decoded = jsonDecode(payload);
      return decoded is Map<String, dynamic> ? decoded : null;
    } on FormatException {
      return null;
    }
  }
}
