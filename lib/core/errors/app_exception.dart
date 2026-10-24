/// Base type of every error that crosses a layer boundary.
///
/// Data sources translate low-level failures (Dio, platform, parsing) into an
/// [AppException] so repositories, controllers and widgets only ever deal
/// with this family. [message] is always safe to show to the user.
abstract class AppException implements Exception {
  const AppException(this.message, {this.code, this.cause});

  /// Human readable, user-safe description.
  final String message;

  /// Optional machine-readable code (e.g. backend error code).
  final String? code;

  /// The original error, kept for logging only. Never shown to users.
  final Object? cause;

  @override
  String toString() => '$runtimeType(code: $code, message: $message)';
}

/// Any failure we cannot classify more precisely.
class UnknownException extends AppException {
  const UnknownException({
    String message = 'Something went wrong. Please try again.',
    super.code,
    super.cause,
  }) : super(message);
}
