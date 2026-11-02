import 'dart:io';

import 'package:dio/dio.dart';

import '../../app/config/api_config.dart';
import '../errors/errors.dart';
import '../utils/app_logger.dart';
import 'api_response.dart';
import 'interceptors/auth_interceptor.dart';

/// Converts the unwrapped response payload into a typed result.
typedef ResponseParser<T> = T Function(Object? data);

/// Single entry point for HTTP. Remote data sources use this; nothing else
/// in the app touches Dio.
///
/// Every method:
/// * unwraps the response envelope ([ApiResponse.unwrap]),
/// * parses it with [ResponseParser],
/// * and converts every failure into an [AppException].
class ApiClient {
  ApiClient(this._dio);

  /// Builds a Dio instance configured from [ApiConfig].
  factory ApiClient.create({List<Interceptor> interceptors = const []}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        sendTimeout: ApiConfig.sendTimeout,
        contentType: Headers.jsonContentType,
        headers: const {'Accept': 'application/json'},
      ),
    )..interceptors.addAll(interceptors);
    return ApiClient(dio);
  }

  final Dio _dio;

  Future<T> get<T>(
    String path, {
    required ResponseParser<T> parser,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    bool authenticated = true,
  }) => _request(
    'GET',
    path,
    parser: parser,
    queryParameters: queryParameters,
    headers: headers,
    authenticated: authenticated,
  );

  Future<T> post<T>(
    String path, {
    required ResponseParser<T> parser,
    Object? body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    bool authenticated = true,
  }) => _request(
    'POST',
    path,
    parser: parser,
    body: body,
    queryParameters: queryParameters,
    headers: headers,
    authenticated: authenticated,
  );

  Future<T> put<T>(
    String path, {
    required ResponseParser<T> parser,
    Object? body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) => _request(
    'PUT',
    path,
    parser: parser,
    body: body,
    queryParameters: queryParameters,
    headers: headers,
  );

  Future<T> patch<T>(
    String path, {
    required ResponseParser<T> parser,
    Object? body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) => _request(
    'PATCH',
    path,
    parser: parser,
    body: body,
    queryParameters: queryParameters,
    headers: headers,
  );

  Future<T> delete<T>(
    String path, {
    required ResponseParser<T> parser,
    Object? body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) => _request(
    'DELETE',
    path,
    parser: parser,
    body: body,
    queryParameters: queryParameters,
    headers: headers,
  );

  Future<T> _request<T>(
    String method,
    String path, {
    required ResponseParser<T> parser,
    Object? body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    bool authenticated = true,
  }) async {
    final Response<Object?> response;
    try {
      response = await _dio.request<Object?>(
        path,
        data: body,
        queryParameters: queryParameters,
        options: Options(
          method: method,
          headers: headers,
          extra: {if (!authenticated) AuthInterceptor.skipAuthKey: true},
        ),
      );
    } on DioException catch (error) {
      throw _mapDioException(error);
    }

    try {
      return parser(ApiResponse.unwrap(response.data));
    } on AppException {
      rethrow;
    } on Object catch (error, stackTrace) {
      AppLogger.error(
        'Failed to parse response of $method $path',
        tag: 'ApiClient',
        error: error,
        stackTrace: stackTrace,
      );
      throw ServerException(
        message: 'We received an unexpected response. Please try again.',
        code: 'parse_error',
        cause: error,
      );
    }
  }

  AppException _mapDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return NetworkException.timeout(cause: error);
      case DioExceptionType.connectionError:
      case DioExceptionType.badCertificate:
        return NetworkException(cause: error);
      case DioExceptionType.cancel:
        return UnknownException(
          message: 'The request was cancelled.',
          code: 'cancelled',
          cause: error,
        );
      case DioExceptionType.badResponse:
        return _mapStatus(error);
      case DioExceptionType.unknown:
        if (error.error is SocketException) {
          return NetworkException(cause: error);
        }
        return UnknownException(cause: error);
    }
  }

  AppException _mapStatus(DioException error) {
    final status = error.response?.statusCode;
    final body = error.response?.data;
    final message = ApiResponse.errorMessage(body);
    final code = ApiResponse.errorCode(body);

    if (status == 401) {
      return message == null
          ? UnauthorizedException(cause: error)
          : UnauthorizedException(message: message, cause: error);
    }
    if (status == 400 || status == 422) {
      return ValidationException(
        message: message ?? const ValidationException().message,
        fieldErrors: ApiResponse.fieldErrors(body),
        code: code,
        cause: error,
      );
    }
    return ServerException(
      message: message ?? const ServerException().message,
      statusCode: status,
      code: code,
      cause: error,
    );
  }
}
