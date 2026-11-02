import 'ad_models.dart';

/// Spreads impressions over the networks in proportion to their weights
/// (smooth weighted round robin). Equal weights simply alternate.
///
/// [order] returns every network, starting with the one whose turn it is,
/// so callers can fall back to the next network when the first has no ad.
/// Only a successful impression ([recordShown]) moves the turns on, which
/// keeps the split right when one network fails to fill.
class AdRotation {
  AdRotation(List<AdNetwork> networks, {Map<AdNetwork, int> weights = const {}})
    : _networks = List.unmodifiable(networks),
      _weights = [for (final n in networks) (weights[n] ?? 1).clamp(0, 1000)],
      _credit = List.filled(networks.length, 0);

  final List<AdNetwork> _networks;
  final List<int> _weights;

  /// Accumulated "right to serve" per network.
  final List<int> _credit;

  List<AdNetwork> get networks => _networks;

  List<AdNetwork> order() {
    final indexes = [
      for (var i = 0; i < _networks.length; i++)
        if (_weights[i] > 0) i,
    ];
    // Highest pending credit first; ties keep the configured order.
    indexes.sort((a, b) {
      final byCredit = (_credit[b] + _weights[b]).compareTo(
        _credit[a] + _weights[a],
      );
      return byCredit != 0 ? byCredit : a.compareTo(b);
    });
    return [for (final i in indexes) _networks[i]];
  }

  /// Records an impression on [network].
  void recordShown(AdNetwork network) {
    final shown = _networks.indexOf(network);
    if (shown < 0) return;
    var total = 0;
    for (var i = 0; i < _networks.length; i++) {
      _credit[i] += _weights[i];
      total += _weights[i];
    }
    _credit[shown] -= total;
  }
}
