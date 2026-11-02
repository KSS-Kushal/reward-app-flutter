import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kavodnik/core/ads/ad_models.dart';
import 'package:kavodnik/core/ads/ad_service.dart';
import 'package:kavodnik/features/rewards/domain/entities/captcha.dart';
import 'package:kavodnik/features/rewards/presentation/providers/reward_claim_controller.dart';
import 'package:kavodnik/features/rewards/presentation/providers/reward_game_controllers.dart';
import 'package:kavodnik/features/wallet/presentation/providers/wallet_providers.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  setUpAll(disableMockLatency);

  Future<int> balance(ProviderContainer container) async =>
      (await container.read(walletProvider.future)).balance;

  group('watch ad → collect', () {
    test('check-in coins arrive only after the ad was watched', () async {
      final container = createTestContainer();
      final sub = container.listen(checkInControllerProvider, (_, _) {});
      addTearDown(sub.close);
      await container.read(checkInControllerProvider.future);
      final before = await balance(container);

      final pending = await container
          .read(checkInControllerProvider.notifier)
          .claim();
      container.invalidate(walletProvider);
      expect(await balance(container), before, reason: 'pending only');

      final claimSub = container.listen(
        rewardClaimProvider(pending),
        (_, _) {},
      );
      addTearDown(claimSub.close);
      await container
          .read(rewardClaimProvider(pending).notifier)
          .watchAdAndCollect();

      final state = container.read(rewardClaimProvider(pending));
      expect(state.phase, RewardClaimPhase.collected);
      expect(state.result?.coinsEarned, pending.coins);
      expect(await balance(container), before + pending.coins);
    });

    for (final (name, outcome, message) in [
      (
        'closing the ad early',
        const RewardedAdDismissed(),
        'Watch the whole ad to collect your coins.',
      ),
      (
        'no ad available',
        const RewardedAdUnavailable(),
        'No ad is available right now. Please try again shortly.',
      ),
    ]) {
      test('$name keeps the coins pending', () async {
        final container = createTestContainer(
          adService: _ScriptedAdService(outcome),
        );
        final sub = container.listen(checkInControllerProvider, (_, _) {});
        addTearDown(sub.close);
        await container.read(checkInControllerProvider.future);
        final before = await balance(container);
        final pending = await container
            .read(checkInControllerProvider.notifier)
            .claim();

        final claimSub = container.listen(
          rewardClaimProvider(pending),
          (_, _) {},
        );
        addTearDown(claimSub.close);
        await container
            .read(rewardClaimProvider(pending).notifier)
            .watchAdAndCollect();

        final state = container.read(rewardClaimProvider(pending));
        expect(state.phase, RewardClaimPhase.ready);
        expect(state.message, message);
        container.invalidate(walletProvider);
        expect(await balance(container), before);
        await container.read(checkInControllerProvider.notifier).reload();
        expect(
          container.read(checkInControllerProvider).value?.pendingReward,
          pending,
        );
      });
    }
  });

  testWidgets('captcha waits 10 seconds before the next challenge', (
    tester,
  ) async {
    final container = createTestContainer();
    final sub = container.listen(captchaControllerProvider, (_, _) {});
    final cooldownSub = container.listen(captchaCooldownProvider, (_, _) {});
    addTearDown(sub.close);
    addTearDown(cooldownSub.close);

    final first = await container.read(captchaControllerProvider.future);
    final result = await container
        .read(captchaControllerProvider.notifier)
        .submit(first.previewText!);

    expect(result.nextChallengeInSeconds, CaptchaResult.defaultCooldownSeconds);
    expect(container.read(captchaCooldownProvider)?.secondsLeft, 10);

    await tester.pump(const Duration(seconds: 9));
    expect(container.read(captchaCooldownProvider)?.secondsLeft, 1);
    expect(container.read(captchaControllerProvider).value?.id, first.id);

    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    expect(container.read(captchaCooldownProvider), isNull);
    final next = container.read(captchaControllerProvider).value;
    expect(next?.id, isNot(first.id));
    expect(next?.remainingAttempts, first.remainingAttempts - 1);
  });
}

class _ScriptedAdService extends DisabledAdService {
  const _ScriptedAdService(this.outcome);

  final RewardedAdOutcome outcome;

  @override
  Future<RewardedAdOutcome> showRewarded({
    required AdPlacement placement,
    String? customData,
  }) async => outcome;
}
