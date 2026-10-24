import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/utils/json_reader.dart';
import '../../../../shared/models/paginated_list.dart';
import '../models/app_notification_model.dart';

abstract interface class NotificationRemoteDataSource {
  Future<PaginatedList<AppNotificationModel>> getNotifications({
    required int page,
    required int pageSize,
  });
  Future<int> getUnreadCount();
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead();
}

class NotificationApiDataSource implements NotificationRemoteDataSource {
  const NotificationApiDataSource(this._client);

  final ApiClient _client;

  @override
  Future<PaginatedList<AppNotificationModel>> getNotifications({
    required int page,
    required int pageSize,
  }) => _client.get(
    ApiEndpoints.notifications,
    queryParameters: {'page': page, 'limit': pageSize},
    parser: (data) => PaginatedList.fromJson(
      ApiResponse.asObject(data),
      AppNotificationModel.fromJson,
    ),
  );

  @override
  Future<int> getUnreadCount() => _client.get(
    ApiEndpoints.notificationsUnreadCount,
    parser: (data) => ApiResponse.asObject(data).readInt('count'),
  );

  @override
  Future<void> markAsRead(String id) =>
      _client.post<void>(ApiEndpoints.notificationRead(id), parser: (_) {});

  @override
  Future<void> markAllAsRead() =>
      _client.post<void>(ApiEndpoints.notificationsReadAll, parser: (_) {});
}
