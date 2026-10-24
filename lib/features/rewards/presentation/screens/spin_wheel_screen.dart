import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/async_value_view.dart';
import '../../../../core/widgets/gradient_page_scaffold.dart';
import '../../../../shared/components/reward_result_dialog.dart';
import '../../domain/entities/spin_wheel.dart';
import '../providers/reward_game_controllers.dart';
import '../widgets/spin_wheel_view.dart';

class SpinWheelScreen extends ConsumerStatefulWidget {
  const SpinWheelScreen({super.key});

  @override
  ConsumerState<SpinWheelScreen> createState() => _SpinWheelScreenState();
}

class _SpinWheelScreenState extends ConsumerState<SpinWheelScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  );
  Animation<double> _rotation = const AlwaysStoppedAnimation(0);
  bool _spinning = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _spin(SpinWheelConfig config) async {
    setState(() => _spinning = true);
    try {
      // The backend decides the prize first; the wheel just lands on it.
      final result = await ref
          .read(spinWheelControllerProvider.notifier)
          .spin();
      final index = config.segments.indexWhere((s) => s.id == result.segmentId);
      final current = _rotation.value;
      _rotation =
          Tween<double>(
            begin: current,
            end: spinTargetAngle(
              currentAngle: current,
              segmentIndex: index < 0 ? 0 : index,
              segmentCount: config.segments.length,
            ),
          ).animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
          );
      await _controller.forward(from: 0);
      if (!mounted) return;
      await RewardResultDialog.show(
        context,
        title: result.coinsWon > 0 ? 'You won!' : 'So close!',
        coins: result.coinsWon,
        message: result.coinsWon > 0 ? null : 'Better luck on your next spin.',
      );
    } on Object catch (error) {
      if (mounted) context.showErrorSnack(error);
    } finally {
      if (mounted) setState(() => _spinning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(spinWheelControllerProvider);
    return GradientPageScaffold(
      title: 'Spin Wheel',
      body: AsyncValueView(
        value: config,
        onRetry: () => ref.invalidate(spinWheelControllerProvider),
        data: (data) => ListView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          children: [
            const Text(
              'Spin to win up to 100 coins',
              textAlign: TextAlign.center,
              style: AppTextStyles.titleMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${data.remainingSpins} of ${data.maxSpinsPerDay} spins left today',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: AppSpacing.xxl),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) => SpinWheelView(
                  segments: data.segments,
                  angle: _rotation.value,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            AppButton(
              label: data.canSpin ? 'Spin now' : 'No spins left today',
              backgroundColor: AppColors.spinAction,
              isLoading: _spinning,
              onPressed: data.canSpin && !_spinning ? () => _spin(data) : null,
            ),
          ],
        ),
      ),
    );
  }
}
