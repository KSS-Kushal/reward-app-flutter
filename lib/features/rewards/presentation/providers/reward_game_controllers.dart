import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../di/rewards_dependencies.dart';
import '../../domain/entities/captcha.dart';
import '../../domain/entities/check_in.dart';
import '../../domain/entities/reward_claim.dart';
import '../../domain/entities/scratch_card.dart';
import '../../domain/entities/spin_wheel.dart';
import 'rewards_providers.dart';

// ---------------------------------------------------------------------------
// Daily check-in
// ---------------------------------------------------------------------------

final checkInControllerProvider =
    AsyncNotifierProvider.autoDispose<CheckInController, CheckInStatus>(
      CheckInController.new,
    );

class CheckInController extends AsyncNotifier<CheckInStatus> {
  @override
  Future<CheckInStatus> build() => ref.read(getCheckInStatusProvider).call();

  /// Starts today's check-in and returns the reward waiting for an ad.
  /// Throws on failure so the UI can show the reason.
  Future<PendingReward> claim() async {
    final current = state.value?.pendingReward;
    if (current != null) return current;
    final pending = await ref.read(claimCheckInProvider).call();
    if (ref.mounted) await reload();
    return pending;
  }

  /// Reloads the status without showing a loading state.
  Future<void> reload() async {
    final status = await AsyncValue.guard(
      ref.read(getCheckInStatusProvider).call,
    );
    if (ref.mounted && status.hasValue) state = status;
  }
}

// ---------------------------------------------------------------------------
// Spin wheel
// ---------------------------------------------------------------------------

final spinWheelControllerProvider =
    AsyncNotifierProvider.autoDispose<SpinWheelController, SpinWheelConfig>(
      SpinWheelController.new,
    );

class SpinWheelController extends AsyncNotifier<SpinWheelConfig> {
  @override
  Future<SpinWheelConfig> build() => ref.read(getSpinWheelProvider).call();

  /// Asks the backend for the outcome; the wheel then animates to it.
  /// Won coins are pending until the user watches an ad.
  Future<SpinResult> spin() async {
    final result = await ref.read(spinWheelProvider).call();
    final config = state.value;
    if (config != null && ref.mounted) {
      state = AsyncData(
        SpinWheelConfig(
          segments: config.segments,
          remainingSpins: result.remainingSpins,
          maxSpinsPerDay: config.maxSpinsPerDay,
          pendingRewards: config.pendingRewards,
        ),
      );
    }
    if (ref.mounted) ref.invalidate(dailyRewardsProvider);
    return result;
  }

  /// Reloads spins left and uncollected prizes, without a loading state.
  Future<void> reload() async {
    final config = await AsyncValue.guard(ref.read(getSpinWheelProvider).call);
    if (ref.mounted && config.hasValue) state = config;
  }
}

// ---------------------------------------------------------------------------
// Scratch card
// ---------------------------------------------------------------------------

final scratchCardControllerProvider =
    AsyncNotifierProvider.autoDispose<ScratchCardController, ScratchCardStatus>(
      ScratchCardController.new,
    );

class ScratchCardController extends AsyncNotifier<ScratchCardStatus> {
  @override
  Future<ScratchCardStatus> build() => ref.read(getScratchCardProvider).call();

  /// Reveals the prize. The coins are pending until the user watches an ad.
  Future<ScratchResult> reveal(String cardId) async {
    final result = await ref.read(revealScratchCardProvider).call(cardId);
    if (ref.mounted) ref.invalidate(dailyRewardsProvider);
    return result;
  }

  /// Loads the next card after a result was shown.
  Future<void> next() async {
    state = const AsyncLoading();
    final next = await AsyncValue.guard(ref.read(getScratchCardProvider).call);
    if (ref.mounted) state = next;
  }
}

// ---------------------------------------------------------------------------
// Captcha
// ---------------------------------------------------------------------------

final captchaControllerProvider =
    AsyncNotifierProvider.autoDispose<CaptchaController, CaptchaChallenge>(
      CaptchaController.new,
    );

class CaptchaController extends AsyncNotifier<CaptchaChallenge> {
  @override
  Future<CaptchaChallenge> build() => ref.read(getCaptchaProvider).call();

  /// Checks the answer, then waits the backend's cooldown before the next
  /// captcha loads (see [captchaCooldownProvider]).
  Future<CaptchaResult> submit(String answer) async {
    final challenge = state.requireValue;
    final result = await ref
        .read(submitCaptchaProvider)
        .call(challengeId: challenge.id, answer: answer);
    if (!ref.mounted) return result;
    refreshAfterEarning(ref);
    if (result.remainingAttempts > 0) {
      ref
          .read(captchaCooldownProvider.notifier)
          .start(result, onFinished: newChallenge);
    } else {
      unawaited(newChallenge());
    }
    return result;
  }

  Future<void> newChallenge() async {
    state = const AsyncLoading();
    final next = await AsyncValue.guard(ref.read(getCaptchaProvider).call);
    if (ref.mounted) state = next;
  }
}

/// Countdown between two captchas, with the result of the last one.
@immutable
class CaptchaCooldown {
  const CaptchaCooldown({
    required this.result,
    required this.secondsLeft,
    required this.totalSeconds,
  });

  final CaptchaResult result;
  final int secondsLeft;
  final int totalSeconds;

  double get progress => totalSeconds == 0 ? 1 : 1 - secondsLeft / totalSeconds;
}

final captchaCooldownProvider =
    NotifierProvider.autoDispose<CaptchaCooldownController, CaptchaCooldown?>(
      CaptchaCooldownController.new,
    );

class CaptchaCooldownController extends Notifier<CaptchaCooldown?> {
  Timer? _timer;

  @override
  CaptchaCooldown? build() {
    ref.onDispose(() => _timer?.cancel());
    return null;
  }

  void start(CaptchaResult result, {required VoidCallback onFinished}) {
    _timer?.cancel();
    final total = result.nextChallengeInSeconds;
    if (total <= 0) {
      onFinished();
      state = null;
      return;
    }
    state = CaptchaCooldown(
      result: result,
      secondsLeft: total,
      totalSeconds: total,
    );
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final current = state;
      final left = (current?.secondsLeft ?? 1) - 1;
      if (current == null || left <= 0) {
        timer.cancel();
        // Start loading first, so the old captcha never flashes back.
        onFinished();
        state = null;
        return;
      }
      state = CaptchaCooldown(
        result: current.result,
        secondsLeft: left,
        totalSeconds: current.totalSeconds,
      );
    });
  }
}
