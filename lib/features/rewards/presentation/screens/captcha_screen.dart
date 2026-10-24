import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_empty_view.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/async_value_view.dart';
import '../../../../core/widgets/coin_icon.dart';
import '../../../../core/widgets/gradient_page_scaffold.dart';
import '../../../../shared/components/reward_result_dialog.dart';
import '../../domain/entities/captcha.dart';
import '../providers/reward_game_controllers.dart';
import '../widgets/captcha_image.dart';

class CaptchaScreen extends ConsumerStatefulWidget {
  const CaptchaScreen({super.key});

  @override
  ConsumerState<CaptchaScreen> createState() => _CaptchaScreenState();
}

class _CaptchaScreenState extends ConsumerState<CaptchaScreen> {
  final _answerController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  CaptchaController get _controller =>
      ref.read(captchaControllerProvider.notifier);

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() => _submitting = true);
    try {
      final result = await _controller.submit(_answerController.text);
      if (!mounted) return;
      _answerController.clear();
      await RewardResultDialog.show(
        context,
        title: result.isCorrect ? 'Correct!' : 'Not quite',
        coins: result.coinsEarned,
        message: result.message,
        actionLabel: result.remainingAttempts > 0 ? 'Next captcha' : 'Done',
      );
      await _controller.newChallenge();
    } on Object catch (error) {
      if (mounted) context.showErrorSnack(error);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final challenge = ref.watch(captchaControllerProvider);
    return GradientPageScaffold(
      title: 'Captcha Task',
      body: AsyncValueView(
        value: challenge,
        onRetry: () => ref.invalidate(captchaControllerProvider),
        isEmpty: (data) => !data.hasAttemptsLeft,
        empty: const AppEmptyView(
          title: "You're done for today",
          message: 'All captcha attempts are used. Come back tomorrow!',
          icon: Icons.verified_user_outlined,
        ),
        data: (data) => ListView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          children: [
            _InfoCard(challenge: data),
            const SizedBox(height: AppSpacing.xxl),
            CaptchaImage(challenge: data),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _submitting ? null : _controller.newChallenge,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('New captcha'),
              ),
            ),
            AppTextField(
              controller: _answerController,
              label: 'Type the characters above',
              hint: 'e.g. A7KQ2P',
              textCapitalization: TextCapitalization.characters,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: 'Submit',
              backgroundColor: AppColors.captchaAction,
              isLoading: _submitting,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.challenge});

  final CaptchaChallenge challenge;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: AppColors.captchaSurface,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Solve & earn', style: AppTextStyles.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${challenge.remainingAttempts} of '
                  '${challenge.totalAttempts} attempts left today',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          CoinAmount(amount: challenge.rewardCoins, showSign: true),
        ],
      ),
    );
  }
}
