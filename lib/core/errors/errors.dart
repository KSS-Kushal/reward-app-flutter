import 'app_exception.dart';

export 'app_exception.dart';
export 'network_exception.dart';
export 'server_exception.dart';
export 'unauthorized_exception.dart';
export 'validation_exception.dart';

/// Converts any thrown object into a message that is safe to display.
///
/// Raw exceptions and stack traces never reach the UI.
String userMessageFor(Object error) {
  if (error is AppException) return error.message;
  return const UnknownException().message;
}
