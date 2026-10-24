import 'package:dio/dio.dart';

import '../../storage/token_storage.dart';
import '../../utils/app_logger.dart';
import '../session_events.dart';

/// Attaches the bearer token to outgoing requests and reports `401`s.
///
/// Requests can opt out (e.g. the login call) with
/// `Options(extra: {AuthInterceptor.skipAuthKey: true})`.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({required this._tokenStorage, required this._sessionEvents});

  static const skipAuthKey = 'skipAuth';

  final TokenStorage _tokenStorage;
  final SessionEvents _sessionEvents;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra[skipAuthKey] != true) {
      final token = await _tokenStorage.readAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final isUnauthorized = err.response?.statusCode == 401;
    final skipped = err.requestOptions.extra[skipAuthKey] == true;
    if (isUnauthorized && !skipped) {
      // A token refresh flow (ApiEndpoints.refreshToken) can be added here
      // once the backend supports it. Until then the session simply ends.
      AppLogger.warning('Received 401, ending session', tag: 'Auth');
      await _tokenStorage.clear();
      _sessionEvents.notifySessionExpired();
    }
    handler.next(err);
  }
}
