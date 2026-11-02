import 'dart:async';

import 'package:unity_ads_plugin/unity_ads_plugin.dart';

import '../../utils/app_logger.dart';
import '../ad_models.dart';
import 'ad_load_slot.dart';
import 'ad_network_client.dart';

/// Unity Ads (unity_ads_plugin). Unity has no native format.
class UnityAdsClient implements AdNetworkClient {
  UnityAdsClient({
    required this.gameId,
    required this.testMode,
    required String rewardedId,
    required String interstitialId,
    required String bannerId,
  }) : rewardedUnit = _unit(rewardedId),
       interstitialUnit = _unit(interstitialId),
       bannerUnit = _unit(bannerId);

  static const _tag = 'UnityAds';

  static AdUnit? _unit(String id) =>
      id.isEmpty ? null : AdUnit(network: AdNetwork.unity, id: id);

  final String gameId;
  final bool testMode;

  @override
  AdNetwork get network => AdNetwork.unity;

  @override
  final AdUnit? rewardedUnit;
  @override
  final AdUnit? interstitialUnit;
  @override
  final AdUnit? bannerUnit;
  @override
  AdUnit? get nativeUnit => null;

  final _rewarded = AdLoadSlot<String>();
  final _interstitial = AdLoadSlot<String>();
  bool _ready = false;

  @override
  bool get isReady => _ready;

  @override
  bool get hasRewarded => _ready && _rewarded.hasAd;

  @override
  bool get hasInterstitial => _ready && _interstitial.hasAd;

  @override
  Future<void> initialize() async {
    if (gameId.isEmpty) return;
    final done = Completer<bool>();
    try {
      await UnityAds.init(
        gameId: gameId,
        testMode: testMode,
        onComplete: () {
          if (!done.isCompleted) done.complete(true);
        },
        onFailed: (error, message) {
          AppLogger.warning(
            'Initialisation failed: $error $message',
            tag: _tag,
          );
          if (!done.isCompleted) done.complete(false);
        },
      );
      _ready = await done.future.timeout(
        const Duration(seconds: 20),
        onTimeout: () => false,
      );
    } on Object catch (error, stackTrace) {
      AppLogger.error(
        'Initialisation threw',
        tag: _tag,
        error: error,
        stackTrace: stackTrace,
      );
    }
    if (!_ready) return;
    AppLogger.info('Initialised (testMode: $testMode)', tag: _tag);
    preloadRewarded();
    preloadInterstitial();
  }

  void _load(AdLoadSlot<String> slot, AdUnit? unit) {
    if (!_ready || unit == null || !slot.begin()) return;
    unawaited(
      UnityAds.load(
        placementId: unit.id,
        onComplete: slot.loaded,
        onFailed: (placementId, error, message) {
          AppLogger.warning(
            '$placementId failed to load: $error $message',
            tag: _tag,
          );
          slot.failed();
        },
      ),
    );
  }

  @override
  void preloadRewarded() => _load(_rewarded, rewardedUnit);

  @override
  void preloadInterstitial() => _load(_interstitial, interstitialUnit);

  @override
  Future<bool> waitForRewarded(Duration timeout) {
    preloadRewarded();
    return _rewarded.wait(timeout);
  }

  /// Shows [slot]'s placement and maps Unity's callbacks to [onComplete],
  /// [onSkipped] or [onFailed].
  Future<T> _show<T>(
    AdLoadSlot<String> slot, {
    required T onComplete,
    required T onSkipped,
    required T onFailed,
    String? serverId,
  }) async {
    final placementId = slot.take();
    if (placementId == null) return onFailed;
    final done = Completer<T>();
    void finish(T value) {
      if (!done.isCompleted) done.complete(value);
    }

    try {
      await UnityAds.showVideoAd(
        placementId: placementId,
        // Reaches the backend's Unity S2S callback as `sid`.
        serverId: serverId,
        onComplete: (_) => finish(onComplete),
        onSkipped: (_) => finish(onSkipped),
        onFailed: (id, error, message) {
          AppLogger.warning('$id failed to show: $error $message', tag: _tag);
          finish(onFailed);
        },
      );
    } on Object catch (error) {
      AppLogger.warning('Show threw', tag: _tag, error: error);
      finish(onFailed);
    }
    return done.future;
  }

  @override
  Future<RewardedAdOutcome> showRewarded({String? customData}) async {
    final unit = rewardedUnit;
    if (unit == null) return const RewardedAdUnavailable();
    final outcome = await _show<RewardedAdOutcome>(
      _rewarded,
      serverId: customData,
      onComplete: RewardedAdEarned(unit),
      onSkipped: const RewardedAdDismissed(),
      onFailed: const RewardedAdUnavailable(),
    );
    preloadRewarded();
    return outcome;
  }

  @override
  Future<bool> showInterstitial() async {
    final shown = await _show<bool>(
      _interstitial,
      onComplete: true,
      onSkipped: true,
      onFailed: false,
    );
    preloadInterstitial();
    return shown;
  }
}
