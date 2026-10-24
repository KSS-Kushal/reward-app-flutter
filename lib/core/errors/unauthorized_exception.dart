import 'app_exception.dart';

/// Missing, expired or revoked session. Triggers a sign-out.
class UnauthorizedException extends AppException {
  const UnauthorizedException({
    String message = defaultMessage,
    super.code,
    super.cause,
  }) : super(message);

  static const defaultMessage =
      'Your session has expired. Please sign in again.';
}
