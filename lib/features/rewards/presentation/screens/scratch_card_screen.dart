import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/errors/errors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_empty_view.dart';
import '../../../../core/widgets/async_value_view.dart';
import '../../../../core/widgets/coin_icon.dart';
import '../../../../core/widgets/gradient_page_scaffold.dart';
import '../../domain/entities/reward_claim.dart';
import '../../domain/entities/scratch_card.dart';
import '../providers/reward_game_controllers.dart';
import '../widgets/pending_reward_card.dart';
import '../widgets/scratch_overlay.dart';
import '../widgets/watch_ad_reward_dialog.dart';

class ScratchCardScreen extends ConsumerWidget {
  const ScratchCardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(scratchCardControllerProvider);
    return GradientPageScaffold(
      title: 'Scratch Card',
      body: AsyncValueView(
        value: status,
        onRetry: () => ref.invalidate(scratchCardControllerProvider),
        isEmpty: (data) => !data.hasCard && data.pendingRewards.isEmpty,
        empty: const AppEmptyView(
          title: 'All cards scratched',
          message:
              'You have used all your scratch cards today. '
              'New cards arrive tomorrow!',
          icon: Icons.style_outlined,
        ),
        data: (data) => _ScratchCardBody(
          // A fresh overlay for every card.
          key: ValueKey(data.cardId),
          status: data,
        ),
      ),
    );
  }
}

class _ScratchCardBody extends ConsumerStatefulWidget {
  const _ScratchCardBody({required this.status, super.key});

  final ScratchCardStatus status;

  @override
  ConsumerState<_ScratchCardBody> createState() => _ScratchCardBodyState();
}

class _ScratchCardBodyState extends ConsumerState<_ScratchCardBody> {
  /// The reveal response: the prize under the foil comes straight from it.
  ScratchResult? _result;
  Object? _error;
  bool _revealed = false;
  bool _collected = false;

  ScratchCardController get _controller =>
      ref.read(scratchCardControllerProvider.notifier);

  /// The prize is decided by the backend as soon as scratching starts. The
  /// POST response is shown directly; no other request is needed.
  Future<void> _startReveal() async {
    try {
      final result = await _controller.reveal(widget.status.cardId!);
      if (!mounted) return;
      setState(() => _result = result);
      _maybeOfferCollect();
    } on Object catch (error) {
      if (mounted) setState(() => _error = error);
    }
  }

  void _onRevealed() {
    setState(() => _revealed = true);
    _maybeOfferCollect();
  }

  /// Opens the "watch ad" dialog once the prize is both decided and visible.
  void _maybeOfferCollect() {
    final pending = _result?.pendingReward;
    if (!mounted || !_revealed || pending == null || _collected) return;
    _collect(pending);
  }

  Future<void> _collect(PendingReward pending) async {
    final claimed = await WatchAdRewardDialog.show(
      context,
      reward: pending,
      title: _result?.message ?? 'You won!',
    );
    if (claimed == null || !mounted) return;
    if (pending.claimId == _result?.pendingReward?.claimId) {
      setState(() => _collected = true);
    } else {
      // An older prize from the list above: refresh that list.
      await _controller.next();
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.status;
    final currentClaim = _result?.pendingReward?.claimId;
    final older = [
      for (final reward in status.pendingRewards)
        if (reward.claimId != currentClaim) reward,
    ];

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        if (older.isNotEmpty) ...[
          PendingRewardCard(
            reward: older.first,
            count: older.length,
            onCollect: () => _collect(older.first),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
        if (status.hasCard) ...[
          const Text(
            'Scratch the card to reveal your prize',
            textAlign: TextAlign.center,
            style: AppTextStyles.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${status.remainingCards} of ${status.totalCards} cards left today',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: AppSpacing.xxl),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: AspectRatio(
                aspectRatio: 1,
                child: ClipRRect(
                  borderRadius: AppRadius.xlAll,
                  child: ScratchOverlay(
                    onScratchStart: _startReveal,
                    onThresholdReached: _onRevealed,
                    child: _Prize(
                      result: _result,
                      error: _error,
                      collected: _collected,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          if (_revealed) _actions(status),
        ] else
          const Text(
            'No cards left today. Collect your prizes before midnight!',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium,
          ),
      ],
    );
  }

  Widget _actions(ScratchCardStatus status) {
    final result = _result;
    final pending = result?.pendingReward;
    final nextLabel = status.remainingCards > 1 ? 'Next card' : 'Done';
    if (result == null) {
      // Still waiting for the backend (or it failed): allow moving on.
      return AppButton(
        label: nextLabel,
        backgroundColor: AppColors.scratchAction,
        onPressed: _error != null ? _controller.next : null,
      );
    }
    if (pending != null && !_collected) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppButton(
            label: 'Watch ad to collect ${result.coinsWon} coins',
            icon: const Icon(Icons.play_circle_fill_rounded),
            backgroundColor: AppColors.scratchAction,
            onPressed: () => _collect(pending),
          ),
          TextButton(onPressed: _controller.next, child: Text(nextLabel)),
        ],
      );
    }
    return AppButton(
      label: nextLabel,
      backgroundColor: AppColors.scratchAction,
      onPressed: _controller.next,
    );
  }
}

/// What is under the foil. Before the reveal response arrives (usually
/// while the first strokes are scratched) it shows a plain coin, never a
/// loader.
class _Prize extends StatelessWidget {
  const _Prize({
    required this.result,
    required this.error,
    required this.collected,
  });

  final ScratchResult? result;
  final Object? error;
  final bool collected;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF4E0), AppColors.scratchSurface],
        ),
      ),
      child: Center(child: _content()),
    );
  }

  Widget _content() {
    final error = this.error;
    if (error != null) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Text(
          userMessageFor(error),
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium,
        ),
      );
    }
    final result = this.result;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CoinIcon(size: 72),
        const SizedBox(height: AppSpacing.md),
        Text(
          result == null ? '? coins' : '+${result.coinsWon} coins',
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.scratchAction,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          result == null
              ? 'Keep scratching!'
              : collected
              ? 'Added to your wallet'
              : result.pendingReward != null
              ? 'Watch an ad to collect'
              : result.message,
          style: AppTextStyles.bodyMedium,
        ),
      ],
    );
  }
}
