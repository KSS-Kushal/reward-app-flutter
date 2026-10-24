import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/app_logger.dart';
import '../../../../shared/models/paginated_list.dart';
import '../../../../shared/models/paginated_state.dart';
import '../../di/notification_dependencies.dart';
import '../../domain/entities/app_notification.dart';

/// Drives the red dot on the home bell.
final unreadNotificationCountProvider = FutureProvider.autoDispose<int>(
  (ref) => ref.watch(getUnreadNotificationCountProvider).call(),
);

final notificationsProvider =
    AsyncNotifierProvider.autoDispose<
      NotificationsController,
      PaginatedState<AppNotification>
    >(NotificationsController.new);

class NotificationsController extends PaginatedController<AppNotification> {
  @override
  Future<PaginatedList<AppNotification>> fetchPage(int page) =>
      ref.read(getNotificationsProvider).call(page: page);

  /// Optimistically marks one notification as read.
  Future<void> markAsRead(AppNotification notification) async {
    if (notification.isRead) return;
    updateItems(
      (items) => [
        for (final n in items) n.id == notification.id ? n.markRead() : n,
      ],
    );
    try {
      await ref.read(markNotificationReadProvider).call(notification.id);
    } on Object catch (error) {
      // Not critical: the server state wins on the next refresh.
      AppLogger.warning('Mark as read failed', error: error);
    }
    if (ref.mounted) ref.invalidate(unreadNotificationCountProvider);
  }

  Future<void> markAllAsRead() async {
    updateItems((items) => [for (final n in items) n.markRead()]);
    try {
      await ref.read(markAllNotificationsReadProvider).call();
    } on Object catch (error) {
      AppLogger.warning('Mark all as read failed', error: error);
    }
    if (ref.mounted) ref.invalidate(unreadNotificationCountProvider);
  }
}
