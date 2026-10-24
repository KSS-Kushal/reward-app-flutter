import '../../../../shared/models/paginated_list.dart';
import '../entities/app_notification.dart';

abstract interface class NotificationRepository {
  Future<PaginatedList<AppNotification>> getNotifications({
    int page = 1,
    int pageSize = 20,
  });

  Future<int> getUnreadCount();

  Future<void> markAsRead(String id);

  Future<void> markAllAsRead();
}
