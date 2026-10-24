import '../../../../core/utils/json_reader.dart';
import '../../domain/entities/auth_session.dart';
import 'user_model.dart';

/// Assumed login response:
/// `{ "accessToken": "...", "refreshToken": "...", "user": { ... } }`
class AuthSessionModel extends AuthSession {
  const AuthSessionModel({
    required super.accessToken,
    required UserModel super.user,
    super.refreshToken,
  });

  factory AuthSessionModel.fromJson(Map<String, dynamic> json) =>
      AuthSessionModel(
        accessToken: json.readString('accessToken'),
        refreshToken: json.readStringOrNull('refreshToken'),
        user: UserModel.fromJson(json.readMap('user')),
      );

  Map<String, dynamic> toJson() => {
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'user': UserModel.fromEntity(user).toJson(),
  };
}
