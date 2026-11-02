import 'dart:async';

import '../utils/app_logger.dart';
import 'ad_models.dart';
import 'ad_rotation.dart';
import 'interstitial_policy.dart';
import 'networks/ad_network_client.dart';

/// The only entry point the app uses for ads. Screens never talk to an ad
/// SDK directly.
abstract interface class AdService {
  bool get isEnabled;

  Future<void> initialize();

  /// Shows a rewarded ad from whichever network's turn it is, falling back
  /// to the other network. [customData] (the reward claim id) is forwarded
  /// to the network's server-side verification callback.
  Future<RewardedAdOutcome> showRewarded({
    required AdPlacement placement,
    String? customData,
  });

  /// Called on every screen change; shows an interstitial now and then.
  Future<void> onScreenChanged();

  /// Banner units to try at [placement], in rotation order. Empty when
  /// banners are off there.
  List<AdUnit> bannerUnits(AdPlacement placement);

  /// Records a banner impression so the next banner uses the other network.
  void recordBannerShown(AdNetwork network);

  /// AdMob native unit for [placement], or `null` when native ads are off.
  AdUnit? nativeUnit(AdPlacement placement);
}

/// Ads switched off (by the admin, by `ADS_ENABLED=false`, or in tests).
/// Rewarded ads count as watched, so reward flows keep working.
class DisabledAdService implements AdService {
  const DisabledAdService();

  /// Sent to the backend as `adNetwork: admob, adUnitId: disabled`.
  static const unit = AdUnit(network: AdNetwork.admob, id: 'disabled');

  @override
  bool get isEnabled => false;

  @override
  Future<void> initialize() async {}

  @override
  Future<RewardedAdOutcome> showRewarded({
    required AdPlacement placement,
    String? customData,
  }) async => const RewardedAdEarned(unit);

  @override
  Future<void> onScreenChanged() async {}

  @override
  List<AdUnit> bannerUnits(AdPlacement placement) => const [];

  @override
  void recordBannerShown(AdNetwork network) {}

  @override
  AdUnit? nativeUnit(AdPlacement placement) => null;
}

/// No ad settings could be loaded: nothing shows, and rewarded ads are
/// reported unavailable (the user can retry later).
class UnavailableAdService extends DisabledAdService {
  const UnavailableAdService();

  @override
  Future<RewardedAdOutcome> showRewarded({
    required AdPlacement placement,
    String? customData,
  }) async => const RewardedAdUnavailable();
}

/// Splits every ad format between the configured networks by their admin
/// share ([weights]); equal weights alternate them.
class MediatedAdService implements AdService {
  MediatedAdService({
    required List<AdNetworkClient> clients,
    required InterstitialPolicy interstitialPolicy,
    Map<AdNetwork, int> weights = const {},
    bool Function(AdPlacement placement, AdFormat format)? allows,
    this.rewardedLoadTimeout = const Duration(seconds: 10),
    this.interstitialDelay = const Duration(milliseconds: 400),
  }) : _clients = {for (final client in clients) client.network: client},
       _policy = interstitialPolicy,
       _allows = allows ?? _allowAll,
       _rewardedRotation = _rotation(clients, weights),
       _interstitialRotation = _rotation(clients, weights),
       _bannerRotation = _rotation(clients, weights);

  static const _tag = 'Ads';

  static bool _allowAll(AdPlacement placement, AdFormat format) => true;

  static AdRotation _rotation(
    List<AdNetworkClient> clients,
    Map<AdNetwork, int> weights,
  ) => AdRotation([for (final c in clients) c.network], weights: weights);

  final Map<AdNetwork, AdNetworkClient> _clients;
  final InterstitialPolicy _policy;
  final bool Function(AdPlacement, AdFormat) _allows;
  final AdRotation _rewardedRotation;
  final AdRotation _interstitialRotation;
  final AdRotation _bannerRotation;

  /// How long a reward flow waits for an ad that is still loading.
  final Duration rewardedLoadTimeout;

  /// Lets the new screen's transition finish before an interstitial.
  final Duration interstitialDelay;

  bool _fullScreenAdShowing = false;

  Iterable<AdNetworkClient> _ordered(AdRotation rotation) => rotation
      .order()
      .map((network) => _clients[network])
      .whereType<AdNetworkClient>()
      .where((client) => client.isReady);

  @override
  bool get isEnabled => true;

  @override
  Future<void> initialize() async {
    await Future.wait(_clients.values.map((client) => client.initialize()));
    AppLogger.info(
      'Ready networks: ${_clients.values.where((c) => c.isReady).map((c) => c.network.name).join(', ')}',
      tag: _tag,
    );
  }

  @override
  Future<RewardedAdOutcome> showRewarded({
    required AdPlacement placement,
    String? customData,
  }) async {
    if (_fullScreenAdShowing) return const RewardedAdUnavailable();
    final candidates = _ordered(_rewardedRotation)
        .where((c) => c.rewardedUnit != null)
        .toList();
    if (candidates.isEmpty) return const RewardedAdUnavailable();

    // Prefer the network whose turn it is, then any network with an ad
    // ready, then wait for whichever finishes loading.
    var client = candidates.firstWhere(
      (c) => c.hasRewarded,
      orElse: () => candidates.first,
    );
    if (!client.hasRewarded) {
      final loaded = await _firstLoaded(candidates);
      if (loaded == null) {
        AppLogger.warning('No rewarded ad for ${placement.name}', tag: _tag);
        return const RewardedAdUnavailable();
      }
      client = loaded;
    }

    _fullScreenAdShowing = true;
    try {
      AppLogger.info(
        'Rewarded (${placement.name}) on ${client.network.name}',
        tag: _tag,
      );
      final outcome = await client.showRewarded(customData: customData);
      if (outcome is! RewardedAdUnavailable) {
        _rewardedRotation.recordShown(client.network);
        _policy.recordFullScreenAd();
      }
      return outcome;
    } finally {
      _fullScreenAdShowing = false;
    }
  }

  /// The first client that finishes loading a rewarded ad, or `null`.
  Future<AdNetworkClient?> _firstLoaded(List<AdNetworkClient> candidates) {
    final first = Completer<AdNetworkClient?>();
    var pending = candidates.length;
    for (final client in candidates) {
      unawaited(
        client.waitForRewarded(rewardedLoadTimeout).then((loaded) {
          pending -= 1;
          if (first.isCompleted) return;
          if (loaded) {
            first.complete(client);
          } else if (pending == 0) {
            first.complete(null);
          }
        }),
      );
    }
    return first.future;
  }

  @override
  Future<void> onScreenChanged() async {
    if (!_allows(AdPlacement.screenChange, AdFormat.interstitial)) return;
    if (_fullScreenAdShowing || !_policy.onScreenChanged()) return;
    final candidates = _ordered(_interstitialRotation).toList();
    final client = candidates.where((c) => c.hasInterstitial).firstOrNull;
    if (client == null) {
      // Nothing loaded yet: load for the next screen change.
      for (final c in candidates) {
        c.preloadInterstitial();
      }
      return;
    }
    _fullScreenAdShowing = true;
    try {
      await Future<void>.delayed(interstitialDelay);
      if (await client.showInterstitial()) {
        AppLogger.info('Interstitial on ${client.network.name}', tag: _tag);
        _interstitialRotation.recordShown(client.network);
        _policy.recordFullScreenAd();
      }
    } finally {
      _fullScreenAdShowing = false;
    }
  }

  @override
  List<AdUnit> bannerUnits(AdPlacement placement) {
    if (!_allows(placement, AdFormat.banner)) return const [];
    return _ordered(_bannerRotation)
        .map((c) => c.bannerUnit)
        .whereType<AdUnit>()
        .toList(growable: false);
  }

  @override
  void recordBannerShown(AdNetwork network) =>
      _bannerRotation.recordShown(network);

  @override
  AdUnit? nativeUnit(AdPlacement placement) {
    if (!_allows(placement, AdFormat.native)) return null;
    return _clients.values
        .where((c) => c.isReady)
        .map((c) => c.nativeUnit)
        .nonNulls
        .firstOrNull;
  }
}
