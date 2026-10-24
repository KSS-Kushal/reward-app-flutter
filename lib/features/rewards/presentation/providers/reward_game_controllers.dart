import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../di/rewards_dependencies.dart';
import '../../domain/entities/captcha.dart';
import '../../domain/entities/check_in.dart';
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

  /// Claims today's reward. Throws on failure so the UI can show the reason.
  Future<CheckInResult> claim() async {
    final result = await ref.read(claimCheckInProvider).call();
    if (!ref.mounted) return result;
    refreshAfterEarning(ref);
    final status = await ref.read(getCheckInStatusProvider).call();
    if (ref.mounted) state = AsyncData(status);
    return result;
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
  Future<SpinResult> spin() async {
    final result = await ref.read(spinWheelProvider).call();
    final config = state.value;
    if (config != null && ref.mounted) {
      state = AsyncData(
        SpinWheelConfig(
          segments: config.segments,
          remainingSpins: result.remainingSpins,
          maxSpinsPerDay: config.maxSpinsPerDay,
        ),
      );
    }
    if (ref.mounted) refreshAfterEarning(ref);
    return result;
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

  Future<ScratchResult> reveal(String cardId) async {
    final result = await ref.read(revealScratchCardProvider).call(cardId);
    if (ref.mounted) refreshAfterEarning(ref);
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

  Future<CaptchaResult> submit(String answer) async {
    final challenge = state.requireValue;
    final result = await ref
        .read(submitCaptchaProvider)
        .call(challengeId: challenge.id, answer: answer);
    if (ref.mounted) refreshAfterEarning(ref);
    return result;
  }

  Future<void> newChallenge() async {
    state = const AsyncLoading();
    final next = await AsyncValue.guard(ref.read(getCaptchaProvider).call);
    if (ref.mounted) state = next;
  }
}
