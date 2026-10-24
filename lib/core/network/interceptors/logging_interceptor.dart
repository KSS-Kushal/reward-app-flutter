import 'dart:convert';

import 'package:dio/dio.dart';

import '../../utils/app_logger.dart';

/// Logs requests and responses for debugging.
///
/// Only added outside production (`AppConfig.enableNetworkLogs`). Bodies are
/// logged with token fields masked and long payloads truncated; headers are
/// never logged.
class LoggingInterceptor extends Interceptor {
  static const _tag = 'Http';
  static const _startKey = 'requestStartedAt';
  static const _maxBodyLength = 2000;

  /// JSON keys whose values are masked in logs.
  static const _sensitiveKeys = {
    'idToken',
    'accessToken',
    'refreshToken',
    'token',
    'password',
  };

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_startKey] = DateTime.now();
    final hasAuth = options.headers.containsKey('Authorization');
    AppLogger.debug(
      '--> ${options.method} ${options.uri}'
      '${hasAuth ? ' [auth]' : ''}'
      '${options.data == null ? '' : '\n   body: ${_format(options.data)}'}',
      tag: _tag,
    );
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    final options = response.requestOptions;
    AppLogger.debug(
      '<-- ${response.statusCode} ${options.method} ${options.uri} '
      '(${_elapsed(options)}ms)\n   body: ${_format(response.data)}',
      tag: _tag,
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final options = err.requestOptions;
    final response = err.response;
    AppLogger.warning(
      '<-- ${response?.statusCode ?? 'NO RESPONSE'} ${options.method} '
      '${options.uri} (${_elapsed(options)}ms)\n'
      '   type: ${err.type.name}\n'
      '   message: ${err.message ?? '<none>'}'
      '${err.error == null ? '' : '\n   cause: ${err.error}'}'
      '${response == null ? '' : '\n   body: ${_format(response.data)}'}'
      '${_hint(err)}',
      tag: _tag,
    );
    handler.next(err);
  }

  /// Extra advice for the most common local-development failures.
  String _hint(DioException err) {
    if (err.type != DioExceptionType.connectionError &&
        err.type != DioExceptionType.connectionTimeout &&
        err.type != DioExceptionType.unknown) {
      return '';
    }
    final host = err.requestOptions.uri.host;
    if (host == 'localhost' || host == '127.0.0.1') {
      return '\n   hint: "$host" on an Android emulator/phone is the device '
          'itself, not your computer. Use http://10.0.2.2:8080/api/v1 on the '
          'emulator, or your computer\'s LAN IP on a real phone.';
    }
    return '\n   hint: is the backend running and reachable from the device? '
        'Plain http:// only works for hosts listed in '
        'android/app/src/debug/res/xml/network_security_config.xml.';
  }

  String _format(Object? data) {
    if (data == null) return '<empty>';
    String text;
    try {
      text = jsonEncode(_redact(data));
    } on Object {
      text = data.toString();
    }
    return text.length > _maxBodyLength
        ? '${text.substring(0, _maxBodyLength)}… (${text.length} chars)'
        : text;
  }

  Object? _redact(Object? value) {
    if (value is Map) {
      return {
        for (final entry in value.entries)
          entry.key.toString(): _sensitiveKeys.contains(entry.key)
              ? AppLogger.mask(entry.value?.toString())
              : _redact(entry.value),
      };
    }
    if (value is List) return value.map(_redact).toList();
    return value;
  }

  int _elapsed(RequestOptions options) {
    final startedAt = options.extra[_startKey];
    if (startedAt is! DateTime) return 0;
    return DateTime.now().difference(startedAt).inMilliseconds;
  }
}
