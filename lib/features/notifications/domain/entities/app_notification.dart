import 'package:flutter/foundation.dart';

enum NotificationType { reward, referral, promotion, system }

@immutable
class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.actionRoute,
  });

  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final DateTime createdAt;
  final bool isRead;

  /// Optional in-app destination opened from the details sheet.
  final String? actionRoute;

  AppNotification markRead() => AppNotification(
    id: id,
    title: title,
    body: body,
    type: type,
    createdAt: createdAt,
    isRead: true,
    actionRoute: actionRoute,
  );
}
