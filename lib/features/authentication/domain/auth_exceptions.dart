import '../../../core/errors/errors.dart';

/// The user dismissed the Google account picker. Not an error to display.
class AuthCancelledException extends AppException {
  const AuthCancelledException() : super('Sign-in was cancelled.');
}

/// Google Sign-In is not configured correctly for this build
/// (missing server client id, SHA-1 fingerprint, etc.).
class AuthConfigurationException extends AppException {
  const AuthConfigurationException({super.cause})
    : super(
        'Google Sign-In is not available right now. Please try again later.',
        code: 'google_config',
      );
}
