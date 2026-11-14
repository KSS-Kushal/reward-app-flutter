import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kavodnik/core/errors/errors.dart';
import 'package:kavodnik/core/network/api_client.dart';
import 'package:kavodnik/core/network/interceptors/auth_interceptor.dart';
import 'package:kavodnik/core/network/session_events.dart';
import 'package:kavodnik/core/network/token_refresher.dart';
import 'package:kavodnik/core/storage/secure_storage_service.dart';
import 'package:kavodnik/core/storage/token_storage.dart';

/// A fake backend: `/wallet` accepts only [validToken], `/auth/refresh`
/// answers with [refreshStatus] and rotates the tokens.
class _FakeBackend implements HttpClientAdapter {
  String validToken = 'new-access';
  int refreshStatus = 200;
  bool refreshThrows = false;
  bool walletAlways401 = false;
  Future<void>? refreshGate;
  Future<void>? walletGate;

  int refreshCalls = 0;
  int walletCalls = 0;
  Object? lastRefreshBody;
  Object? lastRefreshAuthorization;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.path == '/auth/refresh') {
      refreshCalls += 1;
      lastRefreshBody = options.data;
      lastRefreshAuthorization = options.headers['Authorization'];
      await refreshGate;
      if (refreshThrows) {
        throw DioException.connectionError(
          requestOptions: options,
          reason: 'offline',
        );
      }
      if (refreshStatus != 200) {
        return _json(refreshStatus, {
          'success': false,
          'message': 'Refused',
          'code': 'INVALID_REFRESH_TOKEN',
        });
      }
      return _json(200, {
        'success': true,
        'data': {'accessToken': validToken, 'refreshToken': 'new-refresh'},
      });
    }
    walletCalls += 1;
    await walletGate;
    final authorized = options.headers['Authorization'] == 'Bearer $validToken';
    if (walletAlways401 || !authorized) {
      return _json(401, {'success': false, 'message': 'Token expired'});
    }
    return _json(200, {
      'success': true,
      'data': {'balance': 42},
    });
  }

  ResponseBody _json(int status, Object body) => ResponseBody.fromString(
    jsonEncode(body),
    status,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );

  @override
  void close({bool force = false}) {}
}

void main() {
  late TokenStorage tokens;
  late SessionEvents events;
  late _FakeBackend backend;
  late ApiClient api;
  late int sessionsExpired;

  setUp(() async {
    tokens = TokenStorage(InMemorySecureStorageService());
    await tokens.saveTokens(
      accessToken: 'expired-access',
      refreshToken: 'old-refresh',
    );
    events = SessionEvents();
    sessionsExpired = 0;
    events.onSessionExpired.listen((_) => sessionsExpired += 1);
    backend = _FakeBackend();

    Dio dio() =>
        Dio(BaseOptions(baseUrl: 'https://api.test'))
          ..httpClientAdapter = backend;
    api = ApiClient(
      dio()
        ..interceptors.add(
          AuthInterceptor(
            tokenStorage: tokens,
            sessionEvents: events,
            refresher: TokenRefresher(tokenStorage: tokens, dio: dio()),
          ),
        ),
    );
  });

  Future<int> wallet() => api.get(
    '/wallet',
    parser: (data) => (data! as Map<String, dynamic>)['balance'] as int,
  );

  Future<void> expectSessionKept() async {
    await Future<void>.delayed(Duration.zero);
    expect(sessionsExpired, 0);
    expect(await tokens.readRefreshToken(), isNotNull);
  }

  test('an expired token is refreshed and the request retried', () async {
    expect(await wallet(), 42);

    expect(backend.refreshCalls, 1);
    expect(backend.walletCalls, 2);
    expect(backend.lastRefreshBody, {'refreshToken': 'old-refresh'});
    expect(backend.lastRefreshAuthorization, isNull);
    expect(await tokens.readAccessToken(), 'new-access');
    expect(await tokens.readRefreshToken(), 'new-refresh');
    await expectSessionKept();
  });

  test('parallel 401s share a single refresh', () async {
    final results = await Future.wait([for (var i = 0; i < 5; i++) wallet()]);

    expect(results, everyElement(42));
    expect(backend.refreshCalls, 1);
    await expectSessionKept();
  });

  test('a late 401 for an old token retries without refreshing', () async {
    final gate = Completer<void>();
    backend.walletGate = gate.future;

    final request = wallet();
    await pumpEventQueue();
    // The tokens change while the request is on its way.
    await tokens.saveTokens(accessToken: 'new-access');
    gate.complete();

    expect(await request, 42);
    expect(backend.refreshCalls, 0);
    expect(backend.walletCalls, 2);
    await expectSessionKept();
  });

  test('a refused refresh token ends the session', () async {
    backend.refreshStatus = 401;

    await expectLater(wallet(), throwsA(isA<UnauthorizedException>()));
    await Future<void>.delayed(Duration.zero);

    expect(sessionsExpired, 1);
    expect(await tokens.readAccessToken(), isNull);
    expect(await tokens.readRefreshToken(), isNull);
  });

  test('a server error while refreshing keeps the session', () async {
    backend.refreshStatus = 502;

    await expectLater(wallet(), throwsA(isA<NetworkException>()));

    await expectSessionKept();
    expect(await tokens.readAccessToken(), 'expired-access');
    expect(await tokens.readRefreshToken(), 'old-refresh');
  });

  test('being offline while refreshing keeps the session', () async {
    backend.refreshThrows = true;

    await expectLater(wallet(), throwsA(isA<NetworkException>()));

    await expectSessionKept();
    expect(await tokens.readRefreshToken(), 'old-refresh');
  });

  test('refresh works again after a temporary failure', () async {
    backend.refreshStatus = 502;
    await expectLater(wallet(), throwsA(isA<NetworkException>()));

    backend.refreshStatus = 200;
    expect(await wallet(), 42);
    expect(backend.refreshCalls, 2);
  });

  test('a 401 even with fresh tokens fails alone, without logout', () async {
    backend.walletAlways401 = true;

    await expectLater(wallet(), throwsA(isA<UnauthorizedException>()));

    await expectSessionKept();
    expect(backend.refreshCalls, 1);
    expect(backend.walletCalls, 2, reason: 'retried once, no loop');
    expect(await tokens.readAccessToken(), 'new-access');
  });

  test('signing out during a refresh does not restore the tokens', () async {
    final gate = Completer<void>();
    backend.refreshGate = gate.future;

    final request = wallet();
    await pumpEventQueue();
    expect(backend.refreshCalls, 1);
    await tokens.clear();
    gate.complete();

    await expectLater(request, throwsA(isA<UnauthorizedException>()));
    expect(await tokens.readAccessToken(), isNull);
    expect(await tokens.readRefreshToken(), isNull);
  });
}
