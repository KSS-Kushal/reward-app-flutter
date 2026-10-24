import 'app_exception.dart';

/// No connectivity, DNS failure or timeout.
class NetworkException extends AppException {
  const NetworkException({
    String message =
        'Unable to connect. Please check your internet connection.',
    super.code,
    super.cause,
  }) : super(message);

  const NetworkException.timeout({super.cause})
    : super('The request took too long. Please try again.', code: 'timeout');
}
