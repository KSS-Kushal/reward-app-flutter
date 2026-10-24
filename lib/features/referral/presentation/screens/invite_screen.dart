import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/services/external_link_service.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_empty_view.dart';
import '../../../../core/widgets/async_value_view.dart';
import '../../../../core/widgets/coin_icon.dart';
import '../../../../core/widgets/gradient_page_scaffold.dart';
import '../../../../core/widgets/section_header.dart';
import '../../domain/entities/referral.dart';
import '../providers/referral_providers.dart';

class InviteScreen extends ConsumerWidget {
  const InviteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final info = ref.watch(referralInfoProvider);
    return GradientPageScaffold(
      title: 'Invite Friends',
      body: AsyncValueView(
        value: info,
        onRetry: () => ref.invalidate(referralInfoProvider),
        data: (data) => RefreshIndicator(
          onRefresh: () => ref.refresh(referralInfoProvider.future),
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.page),
            children: [
              _ReferralHero(info: data),
              const SizedBox(height: AppSpacing.lg),
              _ReferralStats(info: data),
              const SizedBox(height: AppSpacing.xxl),
              const SectionHeader(
                title: 'How it works',
                icon: Icons.lightbulb_outline_rounded,
              ),
              const SizedBox(height: AppSpacing.md),
              _Steps(reward: data.rewardPerReferral),
              const SizedBox(height: AppSpacing.xxl),
              const SectionHeader(
                title: 'Invited friends',
                icon: Icons.people_outline_rounded,
              ),
              const SizedBox(height: AppSpacing.md),
              if (data.invitedUsers.isEmpty)
                const AppEmptyView(
                  title: 'No invites yet',
                  message: 'Share your code to start earning together.',
                  icon: Icons.group_add_outlined,
                )
              else
                for (final user in data.invitedUsers) ...[
                  _InvitedUserTile(user: user),
                  const SizedBox(height: AppSpacing.sm),
                ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ReferralHero extends ConsumerWidget {
  const _ReferralHero({required this.info});

  final ReferralInfo info;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppCard(
      color: AppColors.inviteFill,
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          const Icon(
            Icons.redeem_rounded,
            size: 56,
            color: AppColors.inviteRing,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Earn ${info.rewardPerReferral} coins for every friend',
            textAlign: TextAlign.center,
            style: AppTextStyles.titleLarge,
          ),
          const SizedBox(height: AppSpacing.lg),
          const Text('Your referral code', style: AppTextStyles.bodySmall),
          const SizedBox(height: AppSpacing.sm),
          Material(
            color: AppColors.surface,
            shape: const StadiumBorder(
              side: BorderSide(color: AppColors.inviteRing),
            ),
            child: InkWell(
              customBorder: const StadiumBorder(),
              onTap: () async {
                await Clipboard.setData(ClipboardData(text: info.code));
                if (context.mounted) context.showSnack('Code copied');
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.md,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      info.code,
                      style: AppTextStyles.titleLarge.copyWith(
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    const Icon(
                      Icons.copy_rounded,
                      size: AppSizes.iconMd,
                      color: AppColors.inviteRing,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: 'Share invite link',
            icon: const Icon(Icons.share_rounded),
            backgroundColor: AppColors.inviteRing,
            onPressed: () => ref
                .read(externalLinkServiceProvider)
                .share(info.shareMessage, subject: 'Join me on Kavodnik'),
          ),
        ],
      ),
    );
  }
}

class _ReferralStats extends StatelessWidget {
  const _ReferralStats({required this.info});

  final ReferralInfo info;

  @override
  Widget build(BuildContext context) {
    Widget stat(String label, String value) => Expanded(
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Text(value, style: AppTextStyles.titleLarge),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodySmall,
            ),
          ],
        ),
      ),
    );

    return Row(
      children: [
        stat('Invited', '${info.totalInvited}'),
        const SizedBox(width: AppSpacing.sm),
        stat('Joined', '${info.successfulReferrals}'),
        const SizedBox(width: AppSpacing.sm),
        stat('Earned', Formatters.compact(info.totalEarned)),
        const SizedBox(width: AppSpacing.sm),
        stat('Pending', Formatters.compact(info.pendingCoins)),
      ],
    );
  }
}

class _Steps extends StatelessWidget {
  const _Steps({required this.reward});

  final int reward;

  @override
  Widget build(BuildContext context) {
    final steps = [
      (Icons.share_rounded, 'Share your code or link with friends'),
      (Icons.person_add_alt_1_rounded, 'Your friend signs up with your code'),
      (Icons.task_alt_rounded, 'They complete their first daily check-in'),
      (Icons.toll_rounded, 'You both earn — you get $reward coins'),
    ];
    return AppCard(
      child: Column(
        children: [
          for (var i = 0; i < steps.length; i++)
            Padding(
              padding: EdgeInsets.only(
                bottom: i == steps.length - 1 ? 0 : AppSpacing.md,
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.primaryLight,
                    child: Icon(
                      steps[i].$1,
                      size: AppSizes.iconSm + 2,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(steps[i].$2, style: AppTextStyles.bodyMedium),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _InvitedUserTile extends StatelessWidget {
  const _InvitedUserTile({required this.user});

  final InvitedUser user;

  @override
  Widget build(BuildContext context) {
    final completed = user.status == ReferralStatus.completed;
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          AppAvatar(name: user.name, imageUrl: user.avatarUrl, size: 40),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Joined ${Formatters.relative(user.joinedAt)}',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          if (completed)
            CoinAmount(amount: user.coinsEarned, showSign: true)
          else
            Text(
              'Pending',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.warning,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }
}
