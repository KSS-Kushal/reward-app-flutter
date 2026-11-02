import '../errors/errors.dart';
import '../utils/json_reader.dart';

/// Knowledge about the backend's response envelope lives here, and only here.
///
/// Contract (see `docs/API_SPEC.md`):
/// ```json
/// { "success": true, "message": "...", "data": {...}, "errors": {...} }
/// ```
/// Responses without an envelope are passed through unchanged.
abstract final class ApiResponse {
  static const _successKey = 'success';
  static const _dataKey = 'data';
  static const _messageKey = 'message';
  static const _errorsKey = 'errors';
  static const _codeKey = 'code';

  /// Returns the payload of a successful response.
  ///
  /// A 2xx response with `"success": false` is still a failure: it is
  /// raised as a [ValidationException] carrying the backend's message.
  static Object? unwrap(Object? body) {
    if (body is! Map<String, dynamic>) return body;
    if (body[_successKey] == false) {
      throw ValidationException(
        message: errorMessage(body) ?? const ValidationException().message,
        fieldErrors: fieldErrors(body),
        code: body.readStringOrNull(_codeKey),
      );
    }
    return body.containsKey(_dataKey) ? body[_dataKey] : body;
  }

  /// Casts an unwrapped payload to a JSON object, failing loudly otherwise.
  static Map<String, dynamic> asObject(Object? data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    throw const ServerException(
      message: 'We received an unexpected response. Please try again.',
      code: 'unexpected_payload',
    );
  }

  /// Casts an unwrapped payload to a list of JSON objects.
  static List<Map<String, dynamic>> asList(Object? data) {
    final list = data is Map<String, dynamic> ? data['items'] : data;
    if (list is! List) {
      throw const ServerException(
        message: 'We received an unexpected response. Please try again.',
        code: 'unexpected_payload',
      );
    }
    return list
        .whereType<Map<dynamic, dynamic>>()
        .map(Map<String, dynamic>.from)
        .toList(growable: false);
  }

  /// Extracts a user-facing error message from an error body, if present.
  static String? errorMessage(Object? body) {
    if (body is Map<String, dynamic>) return body.readStringOrNull(_messageKey);
    return null;
  }

  /// Extracts the machine-readable error `code` (e.g. `ALREADY_CLAIMED`).
  static String? errorCode(Object? body) {
    if (body is Map<String, dynamic>) return body.readStringOrNull(_codeKey);
    return null;
  }

  /// Extracts per-field validation errors from an error body, if present.
  static Map<String, String> fieldErrors(Object? body) {
    if (body is! Map<String, dynamic>) return const {};
    final errors = body.readMap(_errorsKey);
    return errors.map((key, value) {
      final message = value is List && value.isNotEmpty ? value.first : value;
      return MapEntry(key, message.toString());
    });
  }
}
