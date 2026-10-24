import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_empty_view.dart';
import '../../../../core/widgets/feature_icon.dart';
import '../../../../core/widgets/gradient_page_scaffold.dart';
import '../../../../shared/components/paginated_list_view.dart';
import '../../domain/entities/app_notification.dart';
import '../providers/notification_providers.dart';
import '../widgets/notification_item.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  Future<void> _open(
    BuildContext context,
    WidgetRef ref,
    AppNotification notification,
  ) async {
    unawaited(
      ref.read(notificationsProvider.notifier).markAsRead(notification),
    );
    final route = await showModalBottomSheet<String>(
      context: context,
      useRootNavigator: true,
      builder: (_) => _NotificationDetails(notification: notification),
    );
    if (route != null && context.mounted) await context.push(route);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);
    final hasUnread = notifications.value?.items.any((n) => !n.isRead) ?? false;
    final controller = ref.read(notificationsProvider.notifier);

    return GradientPageScaffold(
      title: 'Notifications',
      actions: [
        if (hasUnread)
          TextButton(
            onPressed: controller.markAllAsRead,
            style: TextButton.styleFrom(foregroundColor: AppColors.textOnDark),
            child: const Text('Mark all read'),
          ),
      ],
      body: PaginatedListView(
        value: notifications,
        onRefresh: controller.refresh,
        onLoadMore: controller.loadMore,
        empty: const AppEmptyView(
          title: 'No notifications',
          message:
              "You're all caught up. We'll let you know when "
              'something new arrives.',
          icon: Icons.notifications_none_rounded,
        ),
        itemBuilder: (context, notification) => NotificationItem(
          notification: notification,
          onTap: () => _open(context, ref, notification),
        ),
      ),
    );
  }
}

class _NotificationDetails extends StatelessWidget {
  const _NotificationDetails({required this.notification});

  final AppNotification notification;

  @override
  Widget build(BuildContext context) {
    final route = notification.actionRoute;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xxl,
          0,
          AppSpacing.xxl,
          AppSpacing.xxl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                FeatureIcon(visual: notification.type.visual, size: 44),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    notification.title,
                    style: AppTextStyles.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(notification.body, style: AppTextStyles.bodyLarge),
            const SizedBox(height: AppSpacing.md),
            Text(
              Formatters.dateTime(notification.createdAt),
              style: AppTextStyles.bodySmall,
            ),
            if (route != null) ...[
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                label: 'Open',
                onPressed: () => Navigator.of(context).pop(route),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
