import '../../../../core/utils/json_reader.dart';
import '../../domain/entities/app_notification.dart';

class AppNotificationModel extends AppNotification {
  const AppNotificationModel({
    required super.id,
    required super.title,
    required super.body,
    required super.type,
    required super.createdAt,
    super.isRead,
    super.actionRoute,
  });

  factory AppNotificationModel.fromJson(Map<String, dynamic> json) =>
      AppNotificationModel(
        id: json.readString('id'),
        title: json.readString('title'),
        body: json.readString('body'),
        type: json.readEnum(
          'type',
          NotificationType.values,
          NotificationType.system,
        ),
        createdAt: json.readDateTime('createdAt'),
        isRead: json.readBool('isRead'),
        actionRoute: json.readStringOrNull('actionRoute'),
      );

  factory AppNotificationModel.fromEntity(AppNotification n) =>
      AppNotificationModel(
        id: n.id,
        title: n.title,
        body: n.body,
        type: n.type,
        createdAt: n.createdAt,
        isRead: n.isRead,
        actionRoute: n.actionRoute,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'body': body,
    'type': type.name,
    'createdAt': createdAt.toIso8601String(),
    'isRead': isRead,
    'actionRoute': actionRoute,
  };
}
