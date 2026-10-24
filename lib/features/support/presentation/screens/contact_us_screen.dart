import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/services/external_link_service.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/async_value_view.dart';
import '../../../../core/widgets/gradient_page_scaffold.dart';
import '../../../../core/widgets/section_header.dart';
import '../providers/support_providers.dart';

class ContactUsScreen extends ConsumerWidget {
  const ContactUsScreen({super.key});

  Future<void> _open(
    BuildContext context,
    Future<bool> Function() action,
  ) async {
    final opened = await action();
    if (!opened && context.mounted) {
      context.showSnack('No app available to open this.', isError: true);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final info = ref.watch(supportInfoProvider);
    final links = ref.read(externalLinkServiceProvider);

    return GradientPageScaffold(
      title: 'Contact Us',
      body: AsyncValueView(
        value: info,
        onRetry: () => ref.invalidate(supportInfoProvider),
        data: (data) => ListView(
          padding: const EdgeInsets.all(AppSpacing.page),
          children: [
            const AppCard(
              color: AppColors.contactFill,
              child: Row(
                children: [
                  Icon(
                    Icons.support_agent_rounded,
                    size: 48,
                    color: AppColors.contactRing,
                  ),
                  SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'How can we help?',
                          style: AppTextStyles.titleLarge,
                        ),
                        SizedBox(height: AppSpacing.xs),
                        Text(
                          'Our team usually replies within a few hours.',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _ContactTile(
              icon: Icons.email_outlined,
              title: 'Email us',
              value: data.email,
              onTap: () => _open(
                context,
                () => links.sendEmail(data.email, subject: 'Kavodnik support'),
              ),
            ),
            if (data.phone != null)
              _ContactTile(
                icon: Icons.phone_outlined,
                title: 'Call us',
                value: data.phone!,
                onTap: () => _open(context, () => links.call(data.phone!)),
              ),
            if (data.chatUrl != null)
              _ContactTile(
                icon: Icons.chat_outlined,
                title: 'Chat with us',
                value: 'Start a conversation',
                onTap: () => _open(context, () => links.openUrl(data.chatUrl!)),
              ),
            _ContactTile(
              icon: Icons.schedule_outlined,
              title: 'Support hours',
              value: data.workingHours,
            ),
            const SizedBox(height: AppSpacing.xl),
            const SectionHeader(title: 'FAQ', icon: Icons.help_outline_rounded),
            const SizedBox(height: AppSpacing.md),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (final faq in data.faqs)
                    Theme(
                      data: Theme.of(context)
                          .copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        title: Text(
                          faq.question,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        childrenPadding: const EdgeInsets.fromLTRB(
                          AppSpacing.lg,
                          0,
                          AppSpacing.lg,
                          AppSpacing.lg,
                        ),
                        expandedAlignment: Alignment.centerLeft,
                        children: [
                          Text(faq.answer, style: AppTextStyles.bodySmall),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({
    required this.icon,
    required this.title,
    required this.value,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        onTap: onTap,
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.primaryLight,
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.bodySmall),
                  Text(
                    value,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textTertiary,
              ),
          ],
        ),
      ),
    );
  }
}
