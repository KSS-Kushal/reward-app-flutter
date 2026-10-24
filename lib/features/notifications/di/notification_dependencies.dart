import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/core_providers.dart';
import '../data/datasources/notification_mock_data_source.dart';
import '../data/datasources/notification_remote_data_source.dart';
import '../data/repositories/notification_repository_impl.dart';
import '../domain/repositories/notification_repository.dart';
import '../domain/usecases/notification_usecases.dart';

final notificationRemoteDataSourceProvider =
    Provider<NotificationRemoteDataSource>((ref) {
      if (ref.watch(useMockApiProvider)) return NotificationMockDataSource();
      return NotificationApiDataSource(ref.watch(apiClientProvider));
    });

final notificationRepositoryProvider = Provider<NotificationRepository>(
  (ref) => NotificationRepositoryImpl(
    ref.watch(notificationRemoteDataSourceProvider),
  ),
);

final getNotificationsProvider = Provider(
  (ref) => GetNotifications(ref.watch(notificationRepositoryProvider)),
);
final getUnreadNotificationCountProvider = Provider(
  (ref) =>
      GetUnreadNotificationCount(ref.watch(notificationRepositoryProvider)),
);
final markNotificationReadProvider = Provider(
  (ref) => MarkNotificationRead(ref.watch(notificationRepositoryProvider)),
);
final markAllNotificationsReadProvider = Provider(
  (ref) => MarkAllNotificationsRead(ref.watch(notificationRepositoryProvider)),
);
