import 'package:dio/dio.dart';

import '../storage/token_storage.dart';
import '../utils/app_logger.dart';
import 'api_endpoints.dart';
import 'api_response.dart';

enum TokenRefreshResult {
  /// New tokens are stored; failed requests can be retried.
  refreshed,

  /// The backend refused the refresh token, or there is none: the session
  /// is over.
  rejected,

  /// Network or server trouble: the session may still be valid, so keep it.
  unavailable,
}

/// Exchanges the refresh token for new tokens (`POST /auth/refresh`).
///
/// [_dio] must have no auth interceptor, so its calls can't trigger another
/// refresh.
class TokenRefresher {
  TokenRefresher({required this._tokenStorage, required this._dio});

  static const _tag = 'Auth';

  final TokenStorage _tokenStorage;
  final Dio _dio;

  Future<TokenRefreshResult>? _inFlight;

  /// Parallel callers share one request. The backend rotates refresh tokens,
  /// so a second request with the same token would be refused.
  Future<TokenRefreshResult> refresh() =>
      _inFlight ??= _refresh().whenComplete(() => _inFlight = null);

  /// Sends a failed request again with the current access token.
  Future<Response<dynamic>> retry(RequestOptions options) async {
    final token = await _tokenStorage.readAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    } else {
      options.headers.remove('Authorization');
    }
    return _dio.fetch<dynamic>(options);
  }

  Future<TokenRefreshResult> _refresh() async {
    final sent = await _tokenStorage.readRefreshToken();
    if (sent == null || sent.isEmpty) {
      AppLogger.warning('No refresh token stored', tag: _tag);
      return TokenRefreshResult.rejected;
    }

    final String accessToken;
    final String? refreshToken;
    try {
      final response = await _dio.post<Object?>(
        ApiEndpoints.refreshToken,
        data: {'refreshToken': sent},
      );
      final data = ApiResponse.asObject(ApiResponse.unwrap(response.data));
      final access = data['accessToken'];
      if (access is! String || access.isEmpty) {
        AppLogger.warning('Refresh response has no access token', tag: _tag);
        return TokenRefreshResult.unavailable;
      }
      accessToken = access;
      refreshToken = data['refreshToken'] as String?;
    } on DioException catch (error) {
      final status = error.response?.statusCode;
      AppLogger.warning('Token refresh failed (status: $status)', tag: _tag);
      return await _isSuperseded(sent)
          ? TokenRefreshResult.refreshed
          : status == 401 || status == 403
          ? TokenRefreshResult.rejected
          : TokenRefreshResult.unavailable;
    } on Object catch (error) {
      AppLogger.warning('Token refresh failed', tag: _tag, error: error);
      return TokenRefreshResult.unavailable;
    }

    // Signed out or signed in again meanwhile: don't overwrite that session.
    if (await _isSuperseded(sent)) return TokenRefreshResult.refreshed;
    await _tokenStorage.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
    AppLogger.info('Access token refreshed', tag: _tag);
    return TokenRefreshResult.refreshed;
  }

  Future<bool> _isSuperseded(String sent) async =>
      await _tokenStorage.readRefreshToken() != sent;
}
