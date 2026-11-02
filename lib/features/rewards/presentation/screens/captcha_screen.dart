import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/ads/ad_models.dart';
import '../../../../core/ads/widgets/banner_ad_slot.dart';
import '../../../../core/ads/widgets/native_ad_slot.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_empty_view.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/async_value_view.dart';
import '../../../../core/widgets/coin_icon.dart';
import '../../../../core/widgets/gradient_page_scaffold.dart';
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
      // With attempts left, the cooldown view shows the result instead.
      if (result.remainingAttempts == 0) {
        context.showSnack(result.message, isError: !result.isCorrect);
      }
    } on Object catch (error) {
      if (mounted) context.showErrorSnack(error);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final challenge = ref.watch(captchaControllerProvider);
    final cooldown = ref.watch(captchaCooldownProvider);
    return GradientPageScaffold(
      title: 'Captcha Task',
      bottomBar: const BannerAdSlot(placement: AdPlacement.captcha),
      // One scroll view for every state, so the native ad below stays loaded
      // while the content switches between the form and the countdown.
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            sliver: SliverToBoxAdapter(
              child: cooldown != null
                  ? _CooldownView(cooldown: cooldown)
                  : AsyncValueView(
                      value: challenge,
                      onRetry: () => ref.invalidate(captchaControllerProvider),
                      isEmpty: (data) => !data.hasAttemptsLeft,
                      empty: const AppEmptyView(
                        title: "You're done for today",
                        message: 'All captcha attempts are used. Come back tomorrow!',
                        icon: Icons.verified_user_outlined,
                      ),
                      loading: const Padding(
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      data: (data) => Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _InfoCard(challenge: data),
                          const SizedBox(height: AppSpacing.xxl),
                          CaptchaImage(challenge: data),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: _submitting
                                  ? null
                                  : _controller.newChallenge,
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
            ),
          ),
          const AdaptiveNativeAdSliver(
            placement: AdPlacement.captcha,
            padding: EdgeInsets.fromLTRB(
              AppSpacing.page,
              0,
              AppSpacing.page,
              AppSpacing.lg,
            ),
          ),
        ],
      ),
    );
  }
}

/// Result of the last captcha and the countdown to the next one.
class _CooldownView extends StatelessWidget {
  const _CooldownView({required this.cooldown});

  final CaptchaCooldown cooldown;

  @override
  Widget build(BuildContext context) {
    final result = cooldown.result;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCard(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            children: [
              if (result.isCorrect)
                const CoinIcon(size: 64)
              else
                const Icon(
                  Icons.cancel_rounded,
                  size: 64,
                  color: AppColors.error,
                ),
              const SizedBox(height: AppSpacing.md),
              Text(
                result.isCorrect ? 'Correct!' : 'Not quite',
                style: AppTextStyles.titleLarge,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                result.message,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              if (result.coinsEarned > 0) ...[
                const SizedBox(height: AppSpacing.md),
                CoinAmountBadge(amount: result.coinsEarned),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        Center(
          child: Semantics(
            liveRegion: true,
            label: 'Next captcha in ${cooldown.secondsLeft} seconds',
            excludeSemantics: true,
            child: SizedBox.square(
              dimension: 96,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(end: cooldown.progress),
                    duration: const Duration(seconds: 1),
                    builder: (context, value, _) => CircularProgressIndicator(
                      value: value,
                      strokeWidth: 8,
                      color: AppColors.captchaAction,
                      backgroundColor: AppColors.border,
                    ),
                  ),
                  Center(
                    child: Text(
                      '${cooldown.secondsLeft}s',
                      style: AppTextStyles.headlineMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Next captcha in ${cooldown.secondsLeft} seconds · '
          '${result.remainingAttempts} attempts left today',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySmall,
        ),
      ],
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
