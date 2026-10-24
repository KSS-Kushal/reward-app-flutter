import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/errors/errors.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/auth_exceptions.dart';
import '../../domain/entities/google_credential.dart';

/// Wraps the Google Sign-In SDK so nothing else depends on it.
abstract interface class GoogleAuthService {
  Future<GoogleCredential> signIn();
  Future<void> signOut();
}

class GoogleSignInService implements GoogleAuthService {
  GoogleSignInService({
    required this.serverClientId,
    GoogleSignIn? googleSignIn,
  }) : _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  static const _tag = 'GoogleSignIn';

  /// OAuth web client id of the backend. Required on Android to obtain an
  /// ID token the backend can verify.
  final String serverClientId;
  final GoogleSignIn _googleSignIn;
  Future<void>? _initialization;

  Future<void> _ensureInitialized() {
    return _initialization ??= () async {
      AppLogger.info(
        'Initializing (serverClientId: '
        '${serverClientId.isEmpty ? '<NOT SET>' : serverClientId})',
        tag: _tag,
      );
      if (serverClientId.isEmpty) {
        AppLogger.warning(
          'GOOGLE_SERVER_CLIENT_ID is empty. Android will not return an ID '
          'token. Set it in env/<env>.json (Web OAuth client id).',
          tag: _tag,
        );
      }
      await _googleSignIn.initialize(
        serverClientId: serverClientId.isEmpty ? null : serverClientId,
      );
      AppLogger.debug('Initialized', tag: _tag);
    }();
  }

  @override
  Future<GoogleCredential> signIn() async {
    try {
      await _ensureInitialized();

      final supported = _googleSignIn.supportsAuthenticate();
      AppLogger.debug('supportsAuthenticate: $supported', tag: _tag);
      if (!supported) {
        AppLogger.error(
          'This platform does not support authenticate()',
          tag: _tag,
        );
        throw const AuthConfigurationException();
      }

      AppLogger.info('Opening Google account picker…', tag: _tag);
      final account = await _googleSignIn.authenticate();
      final idToken = account.authentication.idToken;
      AppLogger.info(
        'Account selected: ${account.email} (id: ${account.id}), '
        'idToken: ${AppLogger.mask(idToken)}',
        tag: _tag,
      );

      if (idToken == null || idToken.isEmpty) {
        AppLogger.error(
          'Google returned no ID token. Check that GOOGLE_SERVER_CLIENT_ID is '
          'the *Web application* client id of the same Google Cloud project '
          'as the Android client.',
          tag: _tag,
        );
        throw const AuthConfigurationException();
      }
      return GoogleCredential(
        idToken: idToken,
        email: account.email,
        displayName: account.displayName,
        photoUrl: account.photoUrl,
      );
    } on GoogleSignInException catch (error, stackTrace) {
      _initialization = null;
      AppLogger.error(
        'GoogleSignInException code=${error.code.name} '
        'description=${error.description ?? '<none>'} '
        'details=${error.details ?? '<none>'}',
        tag: _tag,
        stackTrace: stackTrace,
      );
      switch (error.code) {
        case GoogleSignInExceptionCode.canceled:
        case GoogleSignInExceptionCode.interrupted:
          AppLogger.warning(
            'Reported as cancelled. If you did NOT dismiss the dialog, this is '
            'usually a configuration problem:\n'
            '   • Android OAuth client SHA-1 does not match this build '
            '(run: cd android && ./gradlew signingReport)\n'
            '   • Android OAuth client package name is not com.kavodnik.app\n'
            '   • serverClientId is not the Web client id of the same project\n'
            '   • OAuth consent screen is in "Testing" and this Google account '
            'is not added as a test user\n'
            '   • No Google account on the device/emulator, or Google Play '
            'services out of date',
            tag: _tag,
          );
          throw const AuthCancelledException();
        case GoogleSignInExceptionCode.clientConfigurationError:
        case GoogleSignInExceptionCode.providerConfigurationError:
          throw AuthConfigurationException(cause: error);
        // Play services reports console mistakes as unknownError [28444].
        case _ when _isConsoleMisconfiguration(error):
          AppLogger.warning(
            'Google Cloud setup mismatch. The Web client (serverClientId) and '
            'the Android client (package com.kavodnik.app + this build\'s '
            'SHA-1) must be in the SAME project, and the OAuth consent screen '
            'must be configured.',
            tag: _tag,
          );
          throw AuthConfigurationException(cause: error);
        default:
          throw UnknownException(
            message: 'Google Sign-In failed. Please try again.',
            cause: error,
          );
      }
    } on AppException {
      rethrow;
    } on Object catch (error, stackTrace) {
      _initialization = null;
      AppLogger.error(
        'Unexpected error during Google Sign-In',
        tag: _tag,
        error: error,
        stackTrace: stackTrace,
      );
      throw UnknownException(
        message: 'Google Sign-In failed. Please try again.',
        cause: error,
      );
    }
  }

  static bool _isConsoleMisconfiguration(GoogleSignInException error) {
    final description = error.description ?? '';
    return description.contains('28444') ||
        description.contains('Developer console is not set up correctly');
  }

  @override
  Future<void> signOut() async {
    try {
      await _ensureInitialized();
      await _googleSignIn.signOut();
      AppLogger.debug('Signed out of Google', tag: _tag);
    } on Object catch (error) {
      // Signing out of Google is best effort; the app session is already gone.
      AppLogger.warning('Google sign-out failed', tag: _tag, error: error);
    }
  }
}
