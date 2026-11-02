import 'dart:async';

import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../utils/app_logger.dart';
import '../ad_models.dart';
import 'ad_load_slot.dart';
import 'ad_network_client.dart';

/// Google AdMob (google_mobile_ads). Gathers GDPR consent with Google's UMP
/// form before the SDK starts; outside the EEA/UK the form never appears.
class AdMobClient implements AdNetworkClient {
  AdMobClient({
    required String rewardedId,
    required String interstitialId,
    required String bannerId,
    required String nativeId,
  }) : rewardedUnit = _unit(rewardedId),
       interstitialUnit = _unit(interstitialId),
       bannerUnit = _unit(bannerId),
       nativeUnit = _unit(nativeId);

  static const _tag = 'AdMob';

  static AdUnit? _unit(String id) =>
      id.isEmpty ? null : AdUnit(network: AdNetwork.admob, id: id);

  @override
  AdNetwork get network => AdNetwork.admob;

  @override
  final AdUnit? rewardedUnit;
  @override
  final AdUnit? interstitialUnit;
  @override
  final AdUnit? bannerUnit;
  @override
  final AdUnit? nativeUnit;

  final _rewarded = AdLoadSlot<RewardedAd>();
  final _interstitial = AdLoadSlot<InterstitialAd>();
  bool _ready = false;

  @override
  bool get isReady => _ready;

  @override
  bool get hasRewarded => _ready && _rewarded.hasAd;

  @override
  bool get hasInterstitial => _ready && _interstitial.hasAd;

  @override
  Future<void> initialize() async {
    try {
      await _gatherConsent();
      if (!await ConsentInformation.instance.canRequestAds()) {
        AppLogger.warning('Consent does not allow ads; AdMob off', tag: _tag);
        return;
      }
      final status = await MobileAds.instance.initialize();
      _ready = true;
      AppLogger.info(
        'Initialised (${status.adapterStatuses.length} adapters)',
        tag: _tag,
      );
      preloadRewarded();
      preloadInterstitial();
    } on Object catch (error, stackTrace) {
      AppLogger.error(
        'Initialisation failed',
        tag: _tag,
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _gatherConsent() {
    final done = Completer<void>();
    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      () => ConsentForm.loadAndShowConsentFormIfRequired((formError) {
        if (formError != null) {
          AppLogger.warning('Consent form: ${formError.message}', tag: _tag);
        }
        if (!done.isCompleted) done.complete();
      }),
      (error) {
        AppLogger.warning('Consent update failed: ${error.message}', tag: _tag);
        if (!done.isCompleted) done.complete();
      },
    );
    return done.future;
  }

  // ---------------------------------------------------------------------------
  // Rewarded
  // ---------------------------------------------------------------------------

  @override
  void preloadRewarded() {
    final unit = rewardedUnit;
    if (!_ready || unit == null || !_rewarded.begin()) return;
    RewardedAd.load(
      adUnitId: unit.id,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          AppLogger.debug('Rewarded loaded', tag: _tag);
          _rewarded.loaded(ad);
        },
        onAdFailedToLoad: (error) {
          AppLogger.warning(
            'Rewarded failed to load: [${error.code}] ${error.message}',
            tag: _tag,
          );
          _rewarded.failed();
        },
      ),
    );
  }

  @override
  Future<bool> waitForRewarded(Duration timeout) {
    preloadRewarded();
    return _rewarded.wait(timeout);
  }

  @override
  Future<RewardedAdOutcome> showRewarded({String? customData}) async {
    final ad = _rewarded.take();
    final unit = rewardedUnit;
    if (ad == null || unit == null) return const RewardedAdUnavailable();

    final done = Completer<RewardedAdOutcome>();
    var earned = false;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        if (!done.isCompleted) {
          done.complete(
            earned ? RewardedAdEarned(unit) : const RewardedAdDismissed(),
          );
        }
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        AppLogger.warning(
          'Rewarded failed to show: [${error.code}] ${error.message}',
          tag: _tag,
        );
        ad.dispose();
        if (!done.isCompleted) done.complete(const RewardedAdUnavailable());
      },
    );
    try {
      if (customData != null) {
        // Sent to the backend's AdMob SSV callback as `custom_data`.
        await ad.setServerSideOptions(
          ServerSideVerificationOptions(customData: customData),
        );
      }
      await ad.show(onUserEarnedReward: (_, _) => earned = true);
    } on Object catch (error) {
      AppLogger.warning('Rewarded show threw', tag: _tag, error: error);
      unawaited(ad.dispose());
      if (!done.isCompleted) done.complete(const RewardedAdUnavailable());
    }
    final outcome = await done.future;
    preloadRewarded();
    return outcome;
  }

  // ---------------------------------------------------------------------------
  // Interstitial
  // ---------------------------------------------------------------------------

  @override
  void preloadInterstitial() {
    final unit = interstitialUnit;
    if (!_ready || unit == null || !_interstitial.begin()) return;
    InterstitialAd.load(
      adUnitId: unit.id,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: _interstitial.loaded,
        onAdFailedToLoad: (error) {
          AppLogger.warning(
            'Interstitial failed to load: [${error.code}] ${error.message}',
            tag: _tag,
          );
          _interstitial.failed();
        },
      ),
    );
  }

  @override
  Future<bool> showInterstitial() async {
    final ad = _interstitial.take();
    if (ad == null) return false;
    final done = Completer<bool>();
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        if (!done.isCompleted) done.complete(true);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        if (!done.isCompleted) done.complete(false);
      },
    );
    try {
      await ad.show();
    } on Object catch (error) {
      AppLogger.warning('Interstitial show threw', tag: _tag, error: error);
      unawaited(ad.dispose());
      if (!done.isCompleted) done.complete(false);
    }
    final shown = await done.future;
    preloadInterstitial();
    return shown;
  }
}
