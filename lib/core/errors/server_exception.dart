import 'app_exception.dart';

/// The backend responded with an error status (4xx other than 401/422, 5xx).
class ServerException extends AppException {
  const ServerException({
    String message = 'Our servers are having trouble. Please try again later.',
    this.statusCode,
    super.code,
    super.cause,
  }) : super(message);

  final int? statusCode;
}
