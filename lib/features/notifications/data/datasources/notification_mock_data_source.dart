import '../../../../app/router/route_names.dart';
import '../../../../core/mock/mock_latency.dart';
import '../../../../shared/models/paginated_list.dart';
import '../../domain/entities/app_notification.dart';
import '../models/app_notification_model.dart';
import 'notification_remote_data_source.dart';

class NotificationMockDataSource implements NotificationRemoteDataSource {
  NotificationMockDataSource({DateTime? now}) {
    final t = now ?? DateTime.now();
    _items = [
      AppNotificationModel(
        id: 'n1',
        title: 'Your daily check-in is ready',
        body: 'Check in today to keep your streak alive and earn more coins.',
        type: NotificationType.reward,
        createdAt: t.subtract(const Duration(minutes: 25)),
        actionRoute: AppRoutes.dailyCheckIn,
      ),
      AppNotificationModel(
        id: 'n2',
        title: 'Cashback pending',
        body: 'Your Amazon cashback of 340 coins is pending confirmation.',
        type: NotificationType.reward,
        createdAt: t.subtract(const Duration(hours: 20)),
      ),
      AppNotificationModel(
        id: 'n3',
        title: 'Aman joined with your code',
        body: 'You earned 250 coins for inviting a friend. Keep sharing!',
        type: NotificationType.referral,
        createdAt: t.subtract(const Duration(days: 2)),
        isRead: true,
        actionRoute: AppRoutes.invite,
      ),
      AppNotificationModel(
        id: 'n4',
        title: 'Weekend bonus: 2x spins',
        body: 'Spin the wheel this weekend for a chance to win double coins.',
        type: NotificationType.promotion,
        createdAt: t.subtract(const Duration(days: 4)),
        isRead: true,
        actionRoute: AppRoutes.spinWheel,
      ),
      AppNotificationModel(
        id: 'n5',
        title: 'Welcome to Kavodnik',
        body: 'We added 500 welcome coins to your wallet. Happy earning!',
        type: NotificationType.system,
        createdAt: t.subtract(const Duration(days: 30)),
        isRead: true,
      ),
    ];
  }

  late List<AppNotificationModel> _items;

  @override
  Future<PaginatedList<AppNotificationModel>> getNotifications({
    required int page,
    required int pageSize,
  }) async {
    await MockLatency.simulate();
    final start = (page - 1) * pageSize;
    final items = _items.skip(start).take(pageSize).toList(growable: false);
    return PaginatedList(
      items: items,
      page: page,
      pageSize: pageSize,
      totalCount: _items.length,
      hasMore: start + pageSize < _items.length,
    );
  }

  @override
  Future<int> getUnreadCount() async {
    await MockLatency.simulate();
    return _items.where((n) => !n.isRead).length;
  }

  @override
  Future<void> markAsRead(String id) async {
    await MockLatency.simulate(const Duration(milliseconds: 200));
    _items = [
      for (final n in _items)
        n.id == id ? AppNotificationModel.fromEntity(n.markRead()) : n,
    ];
  }

  @override
  Future<void> markAllAsRead() async {
    await MockLatency.simulate(const Duration(milliseconds: 300));
    _items = [
      for (final n in _items) AppNotificationModel.fromEntity(n.markRead()),
    ];
  }
}
