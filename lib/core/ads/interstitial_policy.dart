/// Decides when a screen change may show an interstitial.
///
/// Rules: not during the warm-up after app start, only every
/// [screensBetween] screen changes, and never within [minInterval] of the
/// previous full-screen ad (interstitial *or* rewarded), so users who just
/// watched an ad for coins are not interrupted again.
class InterstitialPolicy {
  InterstitialPolicy({
    required this.screensBetween,
    required this.minInterval,
    required this.warmup,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now {
    _startedAt = _clock();
  }

  final int screensBetween;
  final Duration minInterval;
  final Duration warmup;
  final DateTime Function() _clock;

  late final DateTime _startedAt;
  DateTime? _lastFullScreenAd;
  int _screensSinceAd = 0;

  /// Call on every screen change. Returns `true` when an interstitial
  /// should be shown now.
  bool onScreenChanged() {
    _screensSinceAd += 1;
    final now = _clock();
    if (now.difference(_startedAt) < warmup) return false;
    if (_screensSinceAd < screensBetween) return false;
    final last = _lastFullScreenAd;
    if (last != null && now.difference(last) < minInterval) return false;
    return true;
  }

  /// Call after any full-screen ad was shown.
  void recordFullScreenAd() {
    _lastFullScreenAd = _clock();
    _screensSinceAd = 0;
  }
}
