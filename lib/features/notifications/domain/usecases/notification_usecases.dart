import '../../../../shared/models/paginated_list.dart';
import '../entities/app_notification.dart';
import '../repositories/notification_repository.dart';

class GetNotifications {
  const GetNotifications(this._repository);
  final NotificationRepository _repository;

  Future<PaginatedList<AppNotification>> call({
    int page = 1,
    int pageSize = 20,
  }) => _repository.getNotifications(page: page, pageSize: pageSize);
}

class GetUnreadNotificationCount {
  const GetUnreadNotificationCount(this._repository);
  final NotificationRepository _repository;

  Future<int> call() => _repository.getUnreadCount();
}

class MarkNotificationRead {
  const MarkNotificationRead(this._repository);
  final NotificationRepository _repository;

  Future<void> call(String id) => _repository.markAsRead(id);
}

class MarkAllNotificationsRead {
  const MarkAllNotificationsRead(this._repository);
  final NotificationRepository _repository;

  Future<void> call() => _repository.markAllAsRead();
}
