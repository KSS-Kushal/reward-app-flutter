import '../../../../core/errors/errors.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_mock_data_source.dart';
import '../datasources/auth_remote_data_source.dart';
import '../datasources/google_auth_service.dart';
import '../models/auth_session_model.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({
    required GoogleAuthService googleAuthService,
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
  }) : _google = googleAuthService,
       _remote = remoteDataSource,
       _local = localDataSource;

  final GoogleAuthService _google;
  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;

  static const _tag = 'Auth';

  @override
  Future<User> signInWithGoogle() async {
    AppLogger.info('Step 1/3: Google Sign-In', tag: _tag);
    final credential = await _google.signIn();
    try {
      AppLogger.info(
        'Step 2/3: Exchanging Google ID token with backend '
        '(${_remote.runtimeType})',
        tag: _tag,
      );
      final session = await _remote.loginWithGoogle(
        idToken: credential.idToken,
      );
      AppLogger.info(
        'Step 3/3: Backend accepted. user=${session.user.id} '
        '(${session.user.email}), accessToken: '
        '${AppLogger.mask(session.accessToken)}, refreshToken: '
        '${AppLogger.mask(session.refreshToken)}',
        tag: _tag,
      );
      final user = await _persist(session);
      AppLogger.info('Session saved to secure storage', tag: _tag);
      return user;
    } on Object catch (error, stackTrace) {
      AppLogger.error(
        'Backend login failed after Google sign-in succeeded',
        tag: _tag,
        error: error is AppException ? '$error (cause: ${error.cause})' : error,
        stackTrace: stackTrace,
      );
      // Don't leave the Google account signed in if our backend refused it.
      await _google.signOut();
      rethrow;
    }
  }

  @override
  Future<User> signInAsDemoUser() async {
    final session = await _remote.loginWithGoogle(
      idToken: AuthMockDataSource.demoIdToken,
    );
    return _persist(session);
  }

  @override
  Future<User?> restoreSession() async {
    if (!await _local.hasSession()) return null;
    try {
      final user = await _remote.getCurrentUser();
      await _local.cacheUser(user);
      return user;
    } on UnauthorizedException {
      await _local.clear();
      return null;
    } on NetworkException {
      // Offline start: trust the cached user; requests will re-validate.
      return _local.readCachedUser();
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _remote.logout();
    } on AppException catch (error) {
      AppLogger.warning('Remote logout failed', tag: 'Auth', error: error);
    } finally {
      await _local.clear();
      await _google.signOut();
    }
  }

  @override
  Future<void> clearLocalSession() => _local.clear();

  @override
  Future<void> cacheUser(User user) =>
      _local.cacheUser(UserModel.fromEntity(user));

  Future<User> _persist(AuthSessionModel session) async {
    await _local.saveSession(
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
      user: UserModel.fromEntity(session.user),
    );
    return session.user;
  }
}
