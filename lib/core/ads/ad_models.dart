import 'package:flutter/foundation.dart';

/// Ad networks the app mediates between.
///
/// The JSON value (`name`) is sent to the backend when a reward is collected.
enum AdNetwork { admob, unity }

/// Ad formats. Admin placement switches are keyed by these names.
enum AdFormat { rewarded, interstitial, banner, native }

/// Where an ad is shown. Admin placement switches and reward claims use
/// these names.
enum AdPlacement {
  checkIn,
  spinWheel,
  scratchCard,
  captcha,
  quiz,
  article,
  screenChange,
}

/// A configured ad unit of one network.
@immutable
class AdUnit {
  const AdUnit({required this.network, required this.id});

  final AdNetwork network;

  /// AdMob ad unit id or Unity placement id.
  final String id;

  @override
  bool operator ==(Object other) =>
      other is AdUnit && other.network == network && other.id == id;

  @override
  int get hashCode => Object.hash(network, id);

  @override
  String toString() => '${network.name}:$id';
}

/// What happened when a rewarded ad was requested.
sealed class RewardedAdOutcome {
  const RewardedAdOutcome();
}

/// The ad was watched to the end, so the reward may be collected.
final class RewardedAdEarned extends RewardedAdOutcome {
  const RewardedAdEarned(this.unit);

  final AdUnit unit;
}

/// The user closed the ad before it finished.
final class RewardedAdDismissed extends RewardedAdOutcome {
  const RewardedAdDismissed();
}

/// No network could fill or show an ad (offline, no fill, not configured).
final class RewardedAdUnavailable extends RewardedAdOutcome {
  const RewardedAdUnavailable();
}
