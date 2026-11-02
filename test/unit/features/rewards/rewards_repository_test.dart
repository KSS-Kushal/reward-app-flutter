import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:kavodnik/core/ads/ad_models.dart';
import 'package:kavodnik/core/errors/errors.dart';
import 'package:kavodnik/features/rewards/data/datasources/rewards_mock_data_source.dart';
import 'package:kavodnik/features/rewards/data/repositories/rewards_repository_impl.dart';
import 'package:kavodnik/features/rewards/domain/entities/check_in.dart';
import 'package:kavodnik/features/rewards/domain/entities/reward_claim.dart';
import 'package:kavodnik/features/rewards/domain/entities/reward_task.dart';
import 'package:kavodnik/features/rewards/domain/entities/spin_wheel.dart';
import 'package:kavodnik/features/rewards/domain/repositories/rewards_repository.dart';
import 'package:kavodnik/features/rewards/domain/usecases/rewards_usecases.dart';
import 'package:kavodnik/features/wallet/data/datasources/mock_wallet_ledger.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  setUpAll(disableMockLatency);

  late MockWalletLedger ledger;
  late RewardsRepositoryImpl repository;
  late DateTime now;

  const adUnit = AdUnit(network: AdNetwork.admob, id: 'test-unit');

  Future<ClaimedReward> complete(PendingReward reward) =>
      repository.completeRewardClaim(
        claimId: reward.claimId,
        adUnit: adUnit,
        placement: AdPlacement.checkIn,
      );

  setUp(() {
    now = DateTime(2026, 10, 13, 9);
    ledger = MockWalletLedger(now: now);
    repository = RewardsRepositoryImpl(
      RewardsMockDataSource(ledger, random: Random(1), clock: () => now),
    );
  });

  test('lists the four daily rewards from the Figma design', () async {
    final tasks = await repository.getDailyRewards();
    expect(tasks.map((t) => t.type), RewardTaskType.values);
    expect(tasks.every((t) => t.isAvailable), isTrue);
  });

  group('daily check-in', () {
    test('claiming only reserves the coins until the ad is watched', () async {
      final before = ledger.wallet.balance;
      final status = await repository.getCheckInStatus();
      expect(status.claimedToday, isFalse);
      expect(
        status.days.where((d) => d.state == CheckInDayState.today),
        hasLength(1),
      );

      final pending = await repository.claimCheckIn();

      expect(pending.source, RewardClaimSource.checkIn);
      expect(pending.coins, status.todayReward);
      expect(ledger.wallet.balance, before, reason: 'not credited yet');
      final waiting = await repository.getCheckInStatus();
      expect(waiting.claimedToday, isFalse);
      expect(waiting.pendingReward, pending);
    });

    test('completing the claim credits the wallet and the streak', () async {
      final before = ledger.wallet.balance;
      final status = await repository.getCheckInStatus();
      final pending = await repository.claimCheckIn();

      final claimed = await complete(pending);

      expect(claimed.coinsEarned, pending.coins);
      expect(claimed.newStreak, status.currentStreak + 1);
      expect(ledger.wallet.balance, before + pending.coins);
      final after = await repository.getCheckInStatus();
      expect(after.claimedToday, isTrue);
      expect(after.pendingReward, isNull);
    });

    test('starting twice returns the same pending claim', () async {
      final first = await repository.claimCheckIn();
      expect(await repository.claimCheckIn(), first);
    });

    test('a claim can be completed only once', () async {
      final pending = await repository.claimCheckIn();
      await complete(pending);
      await expectLater(complete(pending), throwsA(isA<ValidationException>()));
      await expectLater(
        repository.claimCheckIn(),
        throwsA(isA<ValidationException>()),
      );
    });

    test('an uncollected check-in expires at midnight', () async {
      final pending = await repository.claimCheckIn();
      now = now.add(const Duration(days: 1));
      final status = await repository.getCheckInStatus();
      expect(status.claimedToday, isFalse);
      expect(status.pendingReward, isNull);
      await expectLater(complete(pending), throwsA(isA<ValidationException>()));
    });

    test('marks the task completed after collecting', () async {
      await complete(await repository.claimCheckIn());
      final tasks = await repository.getDailyRewards();
      expect(
        tasks.firstWhere((t) => t.type == RewardTaskType.dailyCheckIn).status,
        RewardTaskStatus.completed,
      );
    });
  });

  test('spin prizes are credited only after the ad', () async {
    final before = ledger.wallet.balance;
    SpinResult? win;
    // Random(1) is deterministic; spin until a winning segment.
    for (var i = 0; i < 3 && win == null; i++) {
      final result = await repository.spin();
      if (result.coinsWon > 0) win = result;
    }
    final pending = win!.pendingReward!;
    expect(pending.coins, win.coinsWon);
    expect(ledger.wallet.balance, before);
    expect((await repository.getSpinWheel()).pendingRewards, contains(pending));

    await complete(pending);
    expect(ledger.wallet.balance, before + win.coinsWon);
    expect((await repository.getSpinWheel()).pendingRewards, isEmpty);
  });

  test('spin wheel enforces the daily limit', () async {
    final config = await repository.getSpinWheel();
    for (var i = 0; i < config.maxSpinsPerDay; i++) {
      final result = await repository.spin();
      expect(config.segments.map((s) => s.id), contains(result.segmentId));
    }
    expect((await repository.getSpinWheel()).canSpin, isFalse);
    await expectLater(repository.spin(), throwsA(isA<ValidationException>()));
  });

  test('scratch card reveals a server-decided prize once', () async {
    final before = ledger.wallet.balance;
    final card = await repository.getScratchCard();
    final result = await repository.revealScratchCard(card.cardId!);
    expect(result.coinsWon, greaterThan(0));
    expect(result.pendingReward?.coins, result.coinsWon);
    expect(ledger.wallet.balance, before);
    await complete(result.pendingReward!);
    expect(ledger.wallet.balance, before + result.coinsWon);
    await expectLater(
      repository.revealScratchCard(card.cardId!),
      throwsA(isA<ValidationException>()),
    );
  });

  group('captcha', () {
    test('correct answer earns coins', () async {
      final challenge = await repository.getCaptcha();
      final result = await repository.submitCaptcha(
        challengeId: challenge.id,
        answer: challenge.previewText!.toLowerCase(),
      );
      expect(result.isCorrect, isTrue);
      expect(result.coinsEarned, challenge.rewardCoins);
      expect(result.nextChallengeInSeconds, 10);
    });

    test('wrong answer earns nothing but uses an attempt', () async {
      final challenge = await repository.getCaptcha();
      final result = await repository.submitCaptcha(
        challengeId: challenge.id,
        answer: 'WRONG!',
      );
      expect(result.isCorrect, isFalse);
      expect(result.coinsEarned, 0);
      expect(result.remainingAttempts, challenge.remainingAttempts - 1);
    });

    test('blank answers are rejected before reaching the backend', () {
      expect(
        () => SubmitCaptcha(repository).call(challengeId: 'x', answer: '  '),
        throwsA(isA<ValidationException>()),
      );
    });
  });

  group('CompleteRewardClaim', () {
    const reward = PendingReward(
      claimId: 'c1',
      source: RewardClaimSource.spinWheel,
      coins: 20,
    );

    test('retries while the ad network callback is pending', () async {
      final fake = _FlakyClaimRepository(failures: 2);
      final claimed = await CompleteRewardClaim(
        fake,
        retryDelays: const [Duration.zero, Duration.zero, Duration.zero],
      ).call(reward: reward, adUnit: adUnit, placement: AdPlacement.spinWheel);
      expect(claimed.coinsEarned, 20);
      expect(fake.calls, 3);
    });

    test('gives up after the last retry', () async {
      final fake = _FlakyClaimRepository(failures: 5);
      await expectLater(
        CompleteRewardClaim(fake, retryDelays: const [Duration.zero]).call(
          reward: reward,
          adUnit: adUnit,
          placement: AdPlacement.spinWheel,
        ),
        throwsA(isA<ServerException>()),
      );
      expect(fake.calls, 2);
    });

    test('does not retry other errors', () async {
      final fake = _FlakyClaimRepository(
        failures: 5,
        error: const ValidationException(code: 'CLAIM_EXPIRED'),
      );
      await expectLater(
        CompleteRewardClaim(fake).call(
          reward: reward,
          adUnit: adUnit,
          placement: AdPlacement.spinWheel,
        ),
        throwsA(isA<ValidationException>()),
      );
      expect(fake.calls, 1);
    });
  });
}

/// Fails [failures] times with [error] (default `AD_NOT_VERIFIED`).
class _FlakyClaimRepository implements RewardsRepository {
  _FlakyClaimRepository({
    required this.failures,
    this.error = const ServerException(
      statusCode: 409,
      code: 'AD_NOT_VERIFIED',
    ),
  });

  final int failures;
  final AppException error;
  int calls = 0;

  @override
  Future<ClaimedReward> completeRewardClaim({
    required String claimId,
    required AdUnit adUnit,
    required AdPlacement placement,
  }) async {
    calls += 1;
    if (calls <= failures) throw error;
    return ClaimedReward(
      claimId: claimId,
      source: RewardClaimSource.spinWheel,
      coinsEarned: 20,
      message: 'ok',
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
