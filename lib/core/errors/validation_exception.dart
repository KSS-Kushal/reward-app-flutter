import 'app_exception.dart';

/// The request was rejected because of invalid input (usually HTTP 400/422).
class ValidationException extends AppException {
  const ValidationException({
    String message = 'Please check the information you entered.',
    this.fieldErrors = const {},
    super.code,
    super.cause,
  }) : super(message);

  /// Per-field messages keyed by field name, when the backend provides them.
  final Map<String, String> fieldErrors;
}
