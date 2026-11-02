import '../../utils/json_reader.dart';
import '../ad_models.dart';
import 'ad_settings.dart';

/// Google's public Android test ad units:
/// https://developers.google.com/admob/android/test-ads
abstract final class AdMobTestUnits {
  static const rewarded = 'ca-app-pub-3940256099942544/5224354917';
  static const interstitial = 'ca-app-pub-3940256099942544/1033173712';
  static const banner = 'ca-app-pub-3940256099942544/9214589741';
  static const native = 'ca-app-pub-3940256099942544/2247696110';

  static const all = {
    AdFormat.rewarded: rewarded,
    AdFormat.interstitial: interstitial,
    AdFormat.banner: banner,
    AdFormat.native: native,
  };
}

class AdSettingsModel extends AdSettings {
  const AdSettingsModel({
    required super.enabled,
    required List<AdNetworkSettingsModel> super.networks,
    super.version,
    super.interstitialEveryScreens,
    super.interstitialMinInterval,
    super.interstitialWarmup,
    super.rewardedLoadTimeout,
    super.placements,
  });

  /// Used outside production when the backend has no config yet: AdMob test
  /// ads only, every placement on.
  static const developmentDefaults = AdSettingsModel(
    enabled: true,
    networks: [
      AdNetworkSettingsModel(
        network: AdNetwork.admob,
        enabled: true,
        units: AdMobTestUnits.all,
      ),
    ],
  );

  factory AdSettingsModel.fromJson(Map<String, dynamic> json) {
    final networks = json.readMap('networks');
    final interstitial = json.readMap('interstitial');
    final placements = json.readMap('placements');
    return AdSettingsModel(
      enabled: json.readBool('enabled', fallback: true),
      version: json.readInt('version'),
      networks: [
        for (final network in AdNetwork.values)
          if (networks[network.name] is Map)
            AdNetworkSettingsModel.fromJson(
              network,
              Map<String, dynamic>.from(networks[network.name] as Map),
            ),
      ],
      interstitialEveryScreens: interstitial.readInt(
        'everyScreens',
        fallback: 4,
      ),
      interstitialMinInterval: Duration(
        seconds: interstitial.readInt('minIntervalSeconds', fallback: 90),
      ),
      interstitialWarmup: Duration(
        seconds: interstitial.readInt('warmupSeconds', fallback: 60),
      ),
      rewardedLoadTimeout: Duration(
        seconds: json.readInt('rewardedLoadTimeoutSeconds', fallback: 10),
      ),
      placements: {
        for (final placement in AdPlacement.values)
          if (placements[placement.name] is Map)
            placement: _formatSwitches(
              Map<String, dynamic>.from(placements[placement.name] as Map),
            ),
      },
    );
  }

  static Map<AdFormat, bool> _formatSwitches(Map<String, dynamic> json) => {
    for (final format in AdFormat.values)
      if (json.containsKey(format.name)) format: json.readBool(format.name),
  };

  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    'version': version,
    'networks': {
      for (final network in networks.cast<AdNetworkSettingsModel>())
        network.network.name: network.toJson(),
    },
    'interstitial': {
      'everyScreens': interstitialEveryScreens,
      'minIntervalSeconds': interstitialMinInterval.inSeconds,
      'warmupSeconds': interstitialWarmup.inSeconds,
    },
    'rewardedLoadTimeoutSeconds': rewardedLoadTimeout.inSeconds,
    'placements': {
      for (final entry in placements.entries)
        entry.key.name: {
          for (final format in entry.value.entries)
            format.key.name: format.value,
        },
    },
  };

  /// Development builds: same switches and shares, but AdMob test units and
  /// Unity test mode, so real ads are never requested.
  AdSettingsModel withTestUnits() => AdSettingsModel(
    enabled: enabled,
    version: version,
    networks: [
      for (final network in networks.cast<AdNetworkSettingsModel>())
        AdNetworkSettingsModel(
          network: network.network,
          enabled: network.enabled,
          weight: network.weight,
          gameId: network.gameId,
          testMode: true,
          units: network.network == AdNetwork.admob
              ? AdMobTestUnits.all
              : network.units,
        ),
    ],
    interstitialEveryScreens: interstitialEveryScreens,
    interstitialMinInterval: interstitialMinInterval,
    interstitialWarmup: interstitialWarmup,
    rewardedLoadTimeout: rewardedLoadTimeout,
    placements: placements,
  );
}

class AdNetworkSettingsModel extends AdNetworkSettings {
  const AdNetworkSettingsModel({
    required super.network,
    required super.enabled,
    super.weight,
    super.units,
    super.gameId,
    super.testMode,
  });

  static const _unitKeys = {
    AdFormat.rewarded: 'rewardedId',
    AdFormat.interstitial: 'interstitialId',
    AdFormat.banner: 'bannerId',
    AdFormat.native: 'nativeId',
  };

  factory AdNetworkSettingsModel.fromJson(
    AdNetwork network,
    Map<String, dynamic> json,
  ) => AdNetworkSettingsModel(
    network: network,
    enabled: json.readBool('enabled'),
    weight: json.readInt('weight', fallback: 1),
    gameId: json.readStringOrNull('gameId'),
    testMode: json.readBool('testMode'),
    units: {
      for (final entry in _unitKeys.entries)
        if (json.readStringOrNull(entry.value)?.isNotEmpty ?? false)
          entry.key: json.readString(entry.value),
    },
  );

  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    'weight': weight,
    'gameId': gameId,
    'testMode': testMode,
    for (final entry in _unitKeys.entries) entry.value: units[entry.key],
  };
}
