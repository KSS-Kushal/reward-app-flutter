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
import '../../domain/entities/scratch_card.dart';
import '../providers/reward_game_controllers.dart';
import '../widgets/scratch_overlay.dart';

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
        isEmpty: (data) => !data.hasCard,
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
  Future<ScratchResult>? _reveal;
  bool _revealed = false;

  void _startReveal() {
    // The prize is decided by the backend as soon as scratching starts.
    setState(() {
      _reveal = ref
          .read(scratchCardControllerProvider.notifier)
          .reveal(widget.status.cardId!);
    });
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.status;
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
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
                  onThresholdReached: () => setState(() => _revealed = true),
                  child: _Prize(reveal: _reveal),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        if (_revealed)
          FutureBuilder(
            future: _reveal,
            builder: (context, snapshot) => AppButton(
              label: status.remainingCards > 1 ? 'Next card' : 'Done',
              backgroundColor: AppColors.scratchAction,
              onPressed: snapshot.connectionState == ConnectionState.done
                  ? () =>
                        ref.read(scratchCardControllerProvider.notifier).next()
                  : null,
            ),
          ),
      ],
    );
  }
}

class _Prize extends StatelessWidget {
  const _Prize({required this.reveal});

  final Future<ScratchResult>? reveal;

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
      child: Center(
        child: FutureBuilder<ScratchResult>(
          future: reveal,
          builder: (context, snapshot) {
            if (reveal == null ||
                snapshot.connectionState != ConnectionState.done) {
              return const CircularProgressIndicator(
                color: AppColors.scratchAction,
              );
            }
            if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Text(
                  userMessageFor(snapshot.error!),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium,
                ),
              );
            }
            final result = snapshot.requireData;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CoinIcon(size: 72),
                const SizedBox(height: AppSpacing.md),
                Text(
                  '+${result.coinsWon} coins',
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: AppColors.scratchAction,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(result.message, style: AppTextStyles.bodyMedium),
              ],
            );
          },
        ),
      ),
    );
  }
}
