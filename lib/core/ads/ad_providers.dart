import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/config/ad_config.dart';
import '../di/core_providers.dart';
import 'ad_manager.dart';
import 'ad_models.dart';
import 'ad_service.dart';
import 'interstitial_policy.dart';
import 'networks/ad_network_client.dart';
import 'networks/admob_client.dart';
import 'networks/unity_ads_client.dart';
import 'settings/ad_settings.dart';
import 'settings/ad_settings_model.dart';
import 'settings/ad_settings_repository.dart';
import 'settings/ad_settings_source.dart';

final adSettingsRepositoryProvider = Provider<AdSettingsRepository>(
  (ref) => AdSettingsRepository(
    remote: ref.watch(useMockApiProvider)
        ? const AdSettingsMockSource()
        : AdSettingsApiSource(ref.watch(apiClientProvider)),
    storage: ref.watch(localStorageProvider),
    // Development keeps working (with test ads) before the backend has a
    // config; production shows no ads until it answers once.
    fallback: AdConfig.useTestAds ? AdSettingsModel.developmentDefaults : null,
  ),
);

/// App-wide ad service. Overridden with [DisabledAdService] in tests.
final adServiceProvider = Provider<AdService>((ref) {
  if (!AdConfig.adsEnabled) return const DisabledAdService();
  final settings = ref.watch(adSettingsRepositoryProvider);
  return AdManager(
    loadSettings: () async {
      final loaded = await settings.load();
      if (loaded == null || !AdConfig.useTestAds) return loaded;
      return loaded.withTestUnits();
    },
    createService: buildMediatedAdService,
  );
});

/// Builds the network clients and rules from the admin [settings].
AdService buildMediatedAdService(AdSettings settings) {
  final clients = <AdNetworkClient>[];
  final admob = settings.network(AdNetwork.admob);
  if (admob != null && admob.isUsable) {
    clients.add(
      AdMobClient(
        rewardedId: admob.unit(AdFormat.rewarded),
        interstitialId: admob.unit(AdFormat.interstitial),
        bannerId: admob.unit(AdFormat.banner),
        nativeId: admob.unit(AdFormat.native),
      ),
    );
  }
  final unity = settings.network(AdNetwork.unity);
  if (unity != null && unity.isUsable) {
    clients.add(
      UnityAdsClient(
        gameId: unity.gameId!,
        testMode: unity.testMode,
        rewardedId: unity.unit(AdFormat.rewarded),
        interstitialId: unity.unit(AdFormat.interstitial),
        bannerId: unity.unit(AdFormat.banner),
      ),
    );
  }
  return MediatedAdService(
    clients: clients,
    weights: {for (final n in settings.networks) n.network: n.weight},
    allows: settings.allows,
    rewardedLoadTimeout: settings.rewardedLoadTimeout,
    interstitialPolicy: InterstitialPolicy(
      screensBetween: settings.interstitialEveryScreens,
      minInterval: settings.interstitialMinInterval,
      warmup: settings.interstitialWarmup,
    ),
  );
}
