import '../ad_models.dart';

/// One ad SDK (AdMob, Unity) behind a common interface for full-screen
/// formats. Banner and native views are widgets (`core/ads/widgets`); they
/// only need the [AdUnit]s exposed here.
abstract interface class AdNetworkClient {
  AdNetwork get network;

  /// Initialises the SDK. Never throws; failures leave the client unusable.
  Future<void> initialize();

  /// `false` until [initialize] succeeded (and, for AdMob, consent allows ads).
  bool get isReady;

  AdUnit? get rewardedUnit;
  AdUnit? get interstitialUnit;
  AdUnit? get bannerUnit;

  /// Only AdMob serves native ads.
  AdUnit? get nativeUnit;

  bool get hasRewarded;
  bool get hasInterstitial;

  /// Starts loading if no ad is loaded or loading yet.
  void preloadRewarded();
  void preloadInterstitial();

  /// Completes with `true` once a rewarded ad is loaded, or `false` when
  /// loading fails or [timeout] passes.
  Future<bool> waitForRewarded(Duration timeout);

  /// Shows the loaded rewarded ad. [customData] reaches the backend through
  /// the network's server-to-server reward callback (the reward claim id).
  Future<RewardedAdOutcome> showRewarded({String? customData});

  /// Shows the loaded interstitial. Returns `true` if it was shown.
  Future<bool> showInterstitial();
}
