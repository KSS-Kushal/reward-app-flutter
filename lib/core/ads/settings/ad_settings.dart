import 'package:flutter/foundation.dart';

import '../ad_models.dart';

/// Ad configuration managed in the admin panel (`GET /ads/config`).
@immutable
class AdSettings {
  const AdSettings({
    required this.enabled,
    required this.networks,
    this.version = 0,
    this.interstitialEveryScreens = 4,
    this.interstitialMinInterval = const Duration(seconds: 90),
    this.interstitialWarmup = const Duration(seconds: 60),
    this.rewardedLoadTimeout = const Duration(seconds: 10),
    this.placements = const {},
  });

  /// `false` switches every ad off; rewards are then collected without one.
  final bool enabled;

  /// Increases on every admin change; useful in logs.
  final int version;

  final List<AdNetworkSettings> networks;

  final int interstitialEveryScreens;
  final Duration interstitialMinInterval;
  final Duration interstitialWarmup;

  /// How long "Watch ad & collect" waits for an ad that is still loading.
  final Duration rewardedLoadTimeout;

  /// Per placement on/off switches. Missing entries are on.
  final Map<AdPlacement, Map<AdFormat, bool>> placements;

  bool allows(AdPlacement placement, AdFormat format) =>
      placements[placement]?[format] ?? true;

  AdNetworkSettings? network(AdNetwork network) =>
      networks.where((n) => n.network == network).firstOrNull;
}

/// One ad network as configured by the admin.
@immutable
class AdNetworkSettings {
  const AdNetworkSettings({
    required this.network,
    required this.enabled,
    this.weight = 1,
    this.units = const {},
    this.gameId,
    this.testMode = false,
  });

  final AdNetwork network;
  final bool enabled;

  /// Relative share of impressions (e.g. 50/50, 70/30). 0 = never used.
  final int weight;

  /// AdMob ad unit ids or Unity placement ids, per format.
  final Map<AdFormat, String> units;

  /// Unity game id (Unity only).
  final String? gameId;

  /// Unity test mode (Unity only).
  final bool testMode;

  String unit(AdFormat format) => units[format] ?? '';

  bool get isUsable =>
      enabled &&
      weight > 0 &&
      (network != AdNetwork.unity || (gameId?.isNotEmpty ?? false));
}
