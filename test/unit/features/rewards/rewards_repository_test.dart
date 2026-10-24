import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:kavodnik/core/errors/errors.dart';
import 'package:kavodnik/features/rewards/data/datasources/rewards_mock_data_source.dart';
import 'package:kavodnik/features/rewards/data/repositories/rewards_repository_impl.dart';
import 'package:kavodnik/features/rewards/domain/entities/check_in.dart';
import 'package:kavodnik/features/rewards/domain/entities/reward_task.dart';
import 'package:kavodnik/features/rewards/domain/usecases/rewards_usecases.dart';
import 'package:kavodnik/features/wallet/data/datasources/mock_wallet_ledger.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  setUpAll(disableMockLatency);

  late MockWalletLedger ledger;
  late RewardsRepositoryImpl repository;
  late DateTime now;

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
    test('claiming credits the wallet and extends the streak', () async {
      final before = ledger.wallet.balance;
      final status = await repository.getCheckInStatus();
      expect(status.claimedToday, isFalse);
      expect(
        status.days.where((d) => d.state == CheckInDayState.today),
        hasLength(1),
      );

      final result = await repository.claimCheckIn();

      expect(result.newStreak, status.currentStreak + 1);
      expect(ledger.wallet.balance, before + result.coinsEarned);
      expect((await repository.getCheckInStatus()).claimedToday, isTrue);
    });

    test('cannot be claimed twice on the same day', () async {
      await repository.claimCheckIn();
      await expectLater(
        repository.claimCheckIn(),
        throwsA(isA<ValidationException>()),
      );
    });

    test('resets the next day', () async {
      await repository.claimCheckIn();
      now = now.add(const Duration(days: 1));
      expect((await repository.getCheckInStatus()).claimedToday, isFalse);
    });

    test('marks the task completed after claiming', () async {
      await repository.claimCheckIn();
      final tasks = await repository.getDailyRewards();
      expect(
        tasks.firstWhere((t) => t.type == RewardTaskType.dailyCheckIn).status,
        RewardTaskStatus.completed,
      );
    });
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
    final card = await repository.getScratchCard();
    final result = await repository.revealScratchCard(card.cardId!);
    expect(result.coinsWon, greaterThan(0));
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
}
