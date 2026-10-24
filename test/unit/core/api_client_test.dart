import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kavodnik/core/errors/errors.dart';
import 'package:kavodnik/core/network/api_client.dart';
import 'package:kavodnik/core/network/api_response.dart';
import 'package:kavodnik/core/network/interceptors/auth_interceptor.dart';
import 'package:kavodnik/core/network/session_events.dart';
import 'package:kavodnik/core/storage/secure_storage_service.dart';
import 'package:kavodnik/core/storage/token_storage.dart';
import 'package:kavodnik/core/utils/json_reader.dart';

/// Returns a canned response and records the last request.
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.status, this.body);

  final int status;
  final Object? body;
  RequestOptions? lastRequest;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequest = options;
    return ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late TokenStorage tokens;
  late SessionEvents events;

  setUp(() {
    tokens = TokenStorage(InMemorySecureStorageService());
    events = SessionEvents();
  });

  (ApiClient, _FakeAdapter) client(int status, Object? body) {
    final adapter = _FakeAdapter(status, body);
    final dio = Dio(BaseOptions(baseUrl: 'https://api.test'))
      ..httpClientAdapter = adapter
      ..interceptors.add(
        AuthInterceptor(tokenStorage: tokens, sessionEvents: events),
      );
    return (ApiClient(dio), adapter);
  }

  test('unwraps the data envelope and parses it', () async {
    final (api, _) = client(200, {
      'success': true,
      'data': {'balance': 42},
    });
    final balance = await api.get(
      '/wallet',
      parser: (data) => ApiResponse.asObject(data).readInt('balance'),
    );
    expect(balance, 42);
  });

  test('attaches the bearer token when signed in', () async {
    await tokens.saveTokens(accessToken: 'secret-token');
    final (api, adapter) = client(200, {'data': null});
    await api.get<void>('/users/me', parser: (_) {});
    expect(
      adapter.lastRequest?.headers['Authorization'],
      'Bearer secret-token',
    );
  });

  test('skips the token for unauthenticated calls', () async {
    await tokens.saveTokens(accessToken: 'secret-token');
    final (api, adapter) = client(200, {'data': null});
    await api.post<void>('/auth/google', authenticated: false, parser: (_) {});
    expect(adapter.lastRequest?.headers.containsKey('Authorization'), isFalse);
  });

  test('401 becomes UnauthorizedException and ends the session', () async {
    await tokens.saveTokens(accessToken: 'expired');
    final expired = expectLater(events.onSessionExpired, emits(null));
    final (api, _) = client(401, {'message': 'Token expired'});

    await expectLater(
      api.get<void>('/wallet', parser: (_) {}),
      throwsA(
        isA<UnauthorizedException>().having(
          (e) => e.message,
          'message',
          'Token expired',
        ),
      ),
    );
    await expired;
    expect(await tokens.readAccessToken(), isNull);
  });

  test('422 becomes ValidationException with field errors', () async {
    final (api, _) = client(422, {
      'message': 'Invalid input',
      'errors': {
        'name': ['Name is required'],
      },
    });
    await expectLater(
      api.patch<void>('/users/me', parser: (_) {}),
      throwsA(
        isA<ValidationException>().having(
          (e) => e.fieldErrors['name'],
          'name error',
          'Name is required',
        ),
      ),
    );
  });

  test('500 becomes ServerException with a safe default message', () async {
    final (api, _) = client(500, 'Internal stack trace...');
    await expectLater(
      api.get<void>('/wallet', parser: (_) {}),
      throwsA(
        isA<ServerException>()
            .having((e) => e.statusCode, 'status', 500)
            .having(
              (e) => e.message,
              'message',
              const ServerException().message,
            ),
      ),
    );
  });

  test('success: false on a 200 is treated as a failure', () async {
    final (api, _) = client(200, {
      'success': false,
      'message': 'You have already checked in today.',
      'code': 'ALREADY_CLAIMED',
      'data': null,
    });
    await expectLater(
      api.post<void>('/rewards/check-in/claim', parser: (_) {}),
      throwsA(
        isA<ValidationException>()
            .having((e) => e.message, 'message', contains('already'))
            .having((e) => e.code, 'code', 'ALREADY_CLAIMED'),
      ),
    );
  });

  test('unexpected payloads become ServerException, not a crash', () async {
    final (api, _) = client(200, {'data': 'not an object'});
    await expectLater(
      api.get('/wallet', parser: ApiResponse.asObject),
      throwsA(isA<ServerException>()),
    );
  });

  test('userMessageFor never leaks raw errors', () {
    expect(
      userMessageFor(StateError('internal detail')),
      const UnknownException().message,
    );
  });
}
