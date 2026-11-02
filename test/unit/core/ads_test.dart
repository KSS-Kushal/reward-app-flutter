import 'package:flutter_test/flutter_test.dart';
import 'package:kavodnik/core/ads/ad_models.dart';
import 'package:kavodnik/core/ads/ad_rotation.dart';
import 'package:kavodnik/core/ads/ad_service.dart';
import 'package:kavodnik/core/ads/interstitial_policy.dart';
import 'package:kavodnik/core/ads/networks/ad_network_client.dart';

void main() {
  group('AdRotation', () {
    test('alternates networks after each impression', () {
      final rotation = AdRotation([AdNetwork.admob, AdNetwork.unity]);
      expect(rotation.order(), [AdNetwork.admob, AdNetwork.unity]);
      rotation.recordShown(AdNetwork.admob);
      expect(rotation.order(), [AdNetwork.unity, AdNetwork.admob]);
      rotation.recordShown(AdNetwork.unity);
      expect(rotation.order().first, AdNetwork.admob);
    });

    test('a fallback impression hands the turn to the other network', () {
      final rotation = AdRotation([AdNetwork.admob, AdNetwork.unity])
        // AdMob's turn, but Unity served it.
        ..recordShown(AdNetwork.unity);
      expect(rotation.order().first, AdNetwork.admob);
    });

    test('weights split impressions proportionally', () {
      final rotation = AdRotation(
        [AdNetwork.admob, AdNetwork.unity],
        weights: {AdNetwork.admob: 70, AdNetwork.unity: 30},
      );
      final served = <AdNetwork>[];
      for (var i = 0; i < 10; i++) {
        final next = rotation.order().first;
        served.add(next);
        rotation.recordShown(next);
      }
      expect(served.where((n) => n == AdNetwork.admob), hasLength(7));
      expect(served.where((n) => n == AdNetwork.unity), hasLength(3));
    });

    test('weight 0 takes a network out of rotation', () {
      final rotation = AdRotation(
        [AdNetwork.admob, AdNetwork.unity],
        weights: {AdNetwork.admob: 0},
      );
      expect(rotation.order(), [AdNetwork.unity]);
    });

    test('no networks, no order', () {
      expect(AdRotation(const []).order(), isEmpty);
    });
  });

  group('InterstitialPolicy', () {
    late DateTime now;
    late InterstitialPolicy policy;

    setUp(() {
      now = DateTime(2026, 10, 24, 10);
      policy = InterstitialPolicy(
        screensBetween: 3,
        minInterval: const Duration(seconds: 90),
        warmup: const Duration(seconds: 60),
        clock: () => now,
      );
    });

    test('nothing during the warm-up', () {
      for (var i = 0; i < 10; i++) {
        expect(policy.onScreenChanged(), isFalse);
      }
    });

    test('every N screens, at most once per interval', () {
      now = now.add(const Duration(minutes: 2));
      expect(policy.onScreenChanged(), isFalse);
      expect(policy.onScreenChanged(), isFalse);
      expect(policy.onScreenChanged(), isTrue);
      policy.recordFullScreenAd();

      for (var i = 0; i < 5; i++) {
        expect(policy.onScreenChanged(), isFalse, reason: 'within interval');
      }
      now = now.add(const Duration(seconds: 91));
      expect(policy.onScreenChanged(), isTrue);
    });

    test('a rewarded ad also resets the interval', () {
      now = now.add(const Duration(minutes: 2));
      policy.recordFullScreenAd(); // e.g. watched for a check-in
      for (var i = 0; i < 4; i++) {
        expect(policy.onScreenChanged(), isFalse);
      }
    });
  });

  group('MediatedAdService', () {
    late _FakeClient admob;
    late _FakeClient unity;
    late MediatedAdService service;

    setUp(() {
      admob = _FakeClient(AdNetwork.admob);
      unity = _FakeClient(AdNetwork.unity);
      service = MediatedAdService(
        clients: [admob, unity],
        interstitialPolicy: InterstitialPolicy(
          screensBetween: 1,
          minInterval: Duration.zero,
          warmup: Duration.zero,
        ),
        rewardedLoadTimeout: const Duration(milliseconds: 50),
        interstitialDelay: Duration.zero,
      );
    });

    Future<AdNetwork?> showRewarded() async {
      final outcome = await service.showRewarded(
        placement: AdPlacement.checkIn,
        customData: 'claim_1',
      );
      return outcome is RewardedAdEarned ? outcome.unit.network : null;
    }

    test('splits rewarded ads evenly between networks', () async {
      final served = [for (var i = 0; i < 4; i++) await showRewarded()];
      expect(served, [
        AdNetwork.admob,
        AdNetwork.unity,
        AdNetwork.admob,
        AdNetwork.unity,
      ]);
      expect(admob.customData, ['claim_1', 'claim_1']);
    });

    test('falls back to the other network when one has no ad', () async {
      admob.rewardedFill = false;
      expect(await showRewarded(), AdNetwork.unity);
      expect(await showRewarded(), AdNetwork.unity);
    });

    test('reports unavailable when no network fills', () async {
      admob.rewardedFill = false;
      unity.rewardedFill = false;
      final outcome = await service.showRewarded(
        placement: AdPlacement.spinWheel,
      );
      expect(outcome, isA<RewardedAdUnavailable>());
    });

    test('a dismissed ad is reported as such', () async {
      admob.watchToEnd = false;
      final outcome = await service.showRewarded(
        placement: AdPlacement.scratchCard,
      );
      expect(outcome, isA<RewardedAdDismissed>());
    });

    test('interstitials alternate too', () async {
      await service.onScreenChanged();
      await service.onScreenChanged();
      await service.onScreenChanged();
      expect(admob.interstitialsShown, 2);
      expect(unity.interstitialsShown, 1);
    });

    test('banners rotate and native comes from AdMob only', () {
      expect(service.bannerUnits(AdPlacement.quiz).map((u) => u.network), [
        AdNetwork.admob,
        AdNetwork.unity,
      ]);
      service.recordBannerShown(AdNetwork.admob);
      expect(
        service.bannerUnits(AdPlacement.quiz).first.network,
        AdNetwork.unity,
      );
      expect(service.nativeUnit(AdPlacement.quiz)?.network, AdNetwork.admob);
    });

    test('admin placement switches turn formats off', () async {
      final strict = MediatedAdService(
        clients: [admob, unity],
        interstitialPolicy: InterstitialPolicy(
          screensBetween: 1,
          minInterval: Duration.zero,
          warmup: Duration.zero,
        ),
        interstitialDelay: Duration.zero,
        allows: (placement, format) =>
            !(placement == AdPlacement.quiz && format == AdFormat.native) &&
            !(placement == AdPlacement.captcha && format == AdFormat.banner) &&
            placement != AdPlacement.screenChange,
      );
      expect(strict.nativeUnit(AdPlacement.quiz), isNull);
      expect(strict.nativeUnit(AdPlacement.article), isNotNull);
      expect(strict.bannerUnits(AdPlacement.captcha), isEmpty);
      expect(strict.bannerUnits(AdPlacement.quiz), hasLength(2));
      await strict.onScreenChanged();
      expect(admob.interstitialsShown + unity.interstitialsShown, 0);
    });

    test('networks that failed to start are skipped', () async {
      unity.ready = false;
      expect(service.bannerUnits(AdPlacement.quiz).map((u) => u.network), [
        AdNetwork.admob,
      ]);
      expect(await showRewarded(), AdNetwork.admob);
      expect(await showRewarded(), AdNetwork.admob);
    });
  });

  test('DisabledAdService treats rewarded ads as watched', () async {
    const service = DisabledAdService();
    expect(
      await service.showRewarded(placement: AdPlacement.checkIn),
      isA<RewardedAdEarned>(),
    );
    expect(service.bannerUnits(AdPlacement.quiz), isEmpty);
    expect(service.nativeUnit(AdPlacement.quiz), isNull);
  });
}

class _FakeClient implements AdNetworkClient {
  _FakeClient(this.network);

  @override
  final AdNetwork network;

  bool ready = true;
  bool rewardedFill = true;
  bool watchToEnd = true;
  int interstitialsShown = 0;
  final customData = <String?>[];

  AdUnit _unit(String id) => AdUnit(network: network, id: id);

  @override
  bool get isReady => ready;

  @override
  AdUnit? get rewardedUnit => _unit('rewarded');
  @override
  AdUnit? get interstitialUnit => _unit('interstitial');
  @override
  AdUnit? get bannerUnit => _unit('banner');
  @override
  AdUnit? get nativeUnit => network == AdNetwork.admob ? _unit('native') : null;

  @override
  bool get hasRewarded => rewardedFill;
  @override
  bool get hasInterstitial => true;

  @override
  Future<void> initialize() async {}

  @override
  void preloadRewarded() {}

  @override
  void preloadInterstitial() {}

  @override
  Future<bool> waitForRewarded(Duration timeout) async => rewardedFill;

  @override
  Future<RewardedAdOutcome> showRewarded({String? customData}) async {
    if (!rewardedFill) return const RewardedAdUnavailable();
    this.customData.add(customData);
    return watchToEnd
        ? RewardedAdEarned(rewardedUnit!)
        : const RewardedAdDismissed();
  }

  @override
  Future<bool> showInterstitial() async {
    interstitialsShown += 1;
    return true;
  }
}
