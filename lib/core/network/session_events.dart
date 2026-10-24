import 'dart:async';

/// Broadcasts session-level events from the network layer (e.g. a `401`
/// received by any request) to whoever owns the authentication state.
///
/// This decouples the HTTP stack from the auth feature: the interceptor
/// never needs to know about controllers or routing.
class SessionEvents {
  final _expired = StreamController<void>.broadcast();

  Stream<void> get onSessionExpired => _expired.stream;

  void notifySessionExpired() {
    if (!_expired.isClosed) _expired.add(null);
  }

  Future<void> dispose() => _expired.close();
}
