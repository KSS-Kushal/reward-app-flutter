import 'dart:async';

/// Holds at most one loaded full-screen ad and lets callers wait for it.
class AdLoadSlot<T> {
  T? _ad;
  bool _loading = false;
  final _waiters = <Completer<bool>>[];

  bool get hasAd => _ad != null;

  /// Marks a load as started. Returns `false` if one is loaded or loading.
  bool begin() {
    if (_ad != null || _loading) return false;
    _loading = true;
    return true;
  }

  void loaded(T ad) {
    _loading = false;
    _ad = ad;
    _complete(true);
  }

  void failed() {
    _loading = false;
    _complete(false);
  }

  /// Removes and returns the loaded ad (each ad is shown once).
  T? take() {
    final ad = _ad;
    _ad = null;
    return ad;
  }

  Future<bool> wait(Duration timeout) {
    if (_ad != null) return Future.value(true);
    if (!_loading) return Future.value(false);
    final waiter = Completer<bool>();
    _waiters.add(waiter);
    return waiter.future.timeout(
      timeout,
      onTimeout: () {
        _waiters.remove(waiter);
        return false;
      },
    );
  }

  void _complete(bool success) {
    for (final waiter in _waiters) {
      if (!waiter.isCompleted) waiter.complete(success);
    }
    _waiters.clear();
  }
}
