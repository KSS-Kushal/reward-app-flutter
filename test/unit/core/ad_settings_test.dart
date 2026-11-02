import 'package:flutter_test/flutter_test.dart';
import 'package:kavodnik/core/ads/ad_manager.dart';
import 'package:kavodnik/core/ads/ad_models.dart';
import 'package:kavodnik/core/ads/ad_service.dart';
import 'package:kavodnik/core/ads/settings/ad_settings.dart';
import 'package:kavodnik/core/ads/settings/ad_settings_model.dart';
import 'package:kavodnik/core/ads/settings/ad_settings_repository.dart';
import 'package:kavodnik/core/ads/settings/ad_settings_source.dart';
import 'package:kavodnik/core/errors/errors.dart';
import 'package:kavodnik/core/storage/local_storage_service.dart';

/// `GET /ads/config` example from docs/ADS_BACKEND_CHANGES.md.
const _json = {
  'enabled': true,
  'version': 7,
  'networks': {
    'admob': {
      'enabled': true,
      'weight': 60,
      'rewardedId': 'ca-app-pub-1/1',
      'interstitialId': 'ca-app-pub-1/2',
      'bannerId': 'ca-app-pub-1/3',
      'nativeId': 'ca-app-pub-1/4',
    },
    'unity': {
      'enabled': true,
      'weight': 40,
      'gameId': '5712345',
      'testMode': false,
      'rewardedId': 'Rewarded_Android',
      'interstitialId': 'Interstitial_Android',
      'bannerId': 'Banner_Android',
      'nativeId': null,
    },
  },
  'interstitial': {
    'everyScreens': 5,
    'minIntervalSeconds': 120,
    'warmupSeconds': 30,
  },
  'rewardedLoadTimeoutSeconds': 8,
  'placements': {
    'captcha': {'banner': true},
    'quiz': {'banner': true, 'native': false},
    'article': {'banner': true, 'native': true},
    'screenChange': {'interstitial': true},
  },
};

void main() {
  group('AdSettingsModel', () {
    test('parses the admin config', () {
      final settings = AdSettingsModel.fromJson(_json);
      expect(settings.version, 7);
      final admob = settings.network(AdNetwork.admob)!;
      expect(admob.weight, 60);
      expect(admob.unit(AdFormat.native), 'ca-app-pub-1/4');
      final unity = settings.network(AdNetwork.unity)!;
      expect(unity.gameId, '5712345');
      expect(unity.units.containsKey(AdFormat.native), isFalse);
      expect(unity.isUsable, isTrue);
      expect(settings.interstitialEveryScreens, 5);
      expect(settings.interstitialMinInterval, const Duration(minutes: 2));
      expect(settings.rewardedLoadTimeout, const Duration(seconds: 8));
      expect(settings.allows(AdPlacement.quiz, AdFormat.native), isFalse);
      expect(settings.allows(AdPlacement.quiz, AdFormat.banner), isTrue);
      // Missing switches default to on.
      expect(settings.allows(AdPlacement.captcha, AdFormat.native), isTrue);
    });

    test('round-trips through the cache format', () {
      final settings = AdSettingsModel.fromJson(_json);
      final copy = AdSettingsModel.fromJson(settings.toJson());
      expect(copy.version, 7);
      expect(copy.network(AdNetwork.unity)?.weight, 40);
      expect(copy.allows(AdPlacement.quiz, AdFormat.native), isFalse);
    });

    test('Unity without a game id is not usable', () {
      final settings = AdSettingsModel.fromJson({
        'networks': {
          'unity': {'enabled': true, 'weight': 50},
        },
      });
      expect(settings.network(AdNetwork.unity)?.isUsable, isFalse);
      expect(settings.network(AdNetwork.admob), isNull);
    });

    test('development builds swap in AdMob test units', () {
      final test = AdSettingsModel.fromJson(_json).withTestUnits();
      expect(test.network(AdNetwork.admob)?.units, AdMobTestUnits.all);
      expect(test.network(AdNetwork.admob)?.weight, 60);
      expect(test.network(AdNetwork.unity)?.testMode, isTrue);
      expect(test.allows(AdPlacement.quiz, AdFormat.native), isFalse);
    });
  });

  group('AdSettingsRepository', () {
    late InMemoryLocalStorageService storage;
    setUp(() => storage = InMemoryLocalStorageService());

    AdSettingsRepository repository(
      AdSettingsRemoteSource remote, {
      AdSettingsModel? fallback,
    }) => AdSettingsRepository(
      remote: remote,
      storage: storage,
      fallback: fallback,
    );

    test('uses fresh settings and caches them', () async {
      final loaded = await repository(const _Source(_json)).load();
      expect(loaded?.version, 7);
      final offline = await repository(const _Source(null)).load();
      expect(offline?.version, 7, reason: 'from cache');
    });

    test('falls back when there is no cache', () async {
      expect(await repository(const _Source(null)).load(), isNull);
      final dev = await repository(
        const _Source(null),
        fallback: AdSettingsModel.developmentDefaults,
      ).load();
      expect(dev?.network(AdNetwork.admob)?.units, AdMobTestUnits.all);
    });
  });

  group('AdManager', () {
    AdManager manager(AdSettings? settings) => AdManager(
      loadSettings: () async => settings,
      createService: (_) => const _AlwaysUnavailable(),
    );

    test('admin switch off: rewards are collected without an ad', () async {
      final ads = manager(const AdSettings(enabled: false, networks: []));
      await ads.initialize();
      expect(
        await ads.showRewarded(placement: AdPlacement.checkIn),
        isA<RewardedAdEarned>(),
      );
      expect(ads.bannerUnits(AdPlacement.quiz), isEmpty);
    });

    test('no settings: rewarded ads are unavailable', () async {
      final ads = manager(null);
      await ads.initialize();
      expect(
        await ads.showRewarded(placement: AdPlacement.checkIn),
        isA<RewardedAdUnavailable>(),
      );
    });

    test('enabled settings: delegates to the built service', () async {
      final ads = manager(AdSettingsModel.developmentDefaults);
      // A reward request starts the manager if needed.
      expect(
        await ads.showRewarded(placement: AdPlacement.spinWheel),
        isA<RewardedAdUnavailable>(),
      );
      expect(ads.isEnabled, isTrue);
    });
  });
}

class _Source implements AdSettingsRemoteSource {
  const _Source(this.json);

  final Map<String, dynamic>? json;

  @override
  Future<AdSettingsModel> fetch() async {
    final json = this.json;
    if (json == null) throw const NetworkException();
    return AdSettingsModel.fromJson(json);
  }
}

class _AlwaysUnavailable extends UnavailableAdService {
  const _AlwaysUnavailable();

  @override
  bool get isEnabled => true;
}
