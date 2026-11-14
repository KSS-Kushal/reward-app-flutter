import 'package:dio/dio.dart';

import '../../storage/token_storage.dart';
import '../../utils/app_logger.dart';
import '../session_events.dart';
import '../token_refresher.dart';

/// Attaches the bearer token to outgoing requests and recovers from `401`s.
///
/// A `401` refreshes the tokens and retries the request once. The session
/// ends only when the backend refuses the refresh token. Network or server
/// trouble while refreshing keeps the session, and a request that still gets
/// a `401` with fresh tokens fails alone.
///
/// Requests can opt out (e.g. the login call) with
/// `Options(extra: {AuthInterceptor.skipAuthKey: true})`.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required this._tokenStorage,
    required this._sessionEvents,
    required this._refresher,
  });

  static const skipAuthKey = 'skipAuth';

  final TokenStorage _tokenStorage;
  final SessionEvents _sessionEvents;
  final TokenRefresher _refresher;

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
    if (!isUnauthorized || err.requestOptions.extra[skipAuthKey] == true) {
      handler.next(err);
      return;
    }

    // Tokens changed while this request was on its way: just use the new ones.
    if (await _sentOutdatedToken(err.requestOptions)) {
      await _retry(err.requestOptions, handler);
      return;
    }

    switch (await _refresher.refresh()) {
      case TokenRefreshResult.refreshed:
        await _retry(err.requestOptions, handler);
      case TokenRefreshResult.rejected:
        AppLogger.warning('Refresh rejected, ending session', tag: 'Auth');
        await _tokenStorage.clear();
        _sessionEvents.notifySessionExpired();
        handler.next(err);
      case TokenRefreshResult.unavailable:
        // Reported as a connection problem, so callers keep the session.
        handler.next(
          DioException.connectionError(
            requestOptions: err.requestOptions,
            reason: 'Token refresh is unavailable',
            error: err,
          ),
        );
    }
  }

  Future<bool> _sentOutdatedToken(RequestOptions request) async {
    final current = await _tokenStorage.readAccessToken();
    if (current == null || current.isEmpty) return false;
    return request.headers['Authorization'] != 'Bearer $current';
  }

  Future<void> _retry(
    RequestOptions request,
    ErrorInterceptorHandler handler,
  ) async {
    try {
      handler.resolve(await _refresher.retry(request));
    } on DioException catch (error) {
      handler.next(error);
    }
  }
}
