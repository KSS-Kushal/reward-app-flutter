import '../../../../shared/models/paginated_list.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_data_source.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  const NotificationRepositoryImpl(this._remote);

  final NotificationRemoteDataSource _remote;

  @override
  Future<PaginatedList<AppNotification>> getNotifications({
    int page = 1,
    int pageSize = 20,
  }) => _remote.getNotifications(page: page, pageSize: pageSize);

  @override
  Future<int> getUnreadCount() => _remote.getUnreadCount();

  @override
  Future<void> markAsRead(String id) => _remote.markAsRead(id);

  @override
  Future<void> markAllAsRead() => _remote.markAllAsRead();
}
