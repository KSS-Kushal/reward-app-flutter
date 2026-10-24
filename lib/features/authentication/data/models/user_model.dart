import '../../../../core/utils/json_reader.dart';
import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.joinedAt,
    super.avatarUrl,
    super.phone,
    super.referralCode,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json.readString('id'),
    name: json.readString('name'),
    email: json.readString('email'),
    avatarUrl: json.readStringOrNull('avatarUrl'),
    phone: json.readStringOrNull('phone'),
    referralCode: json.readStringOrNull('referralCode'),
    joinedAt: json.readDateTime('joinedAt'),
  );

  factory UserModel.fromEntity(User user) => UserModel(
    id: user.id,
    name: user.name,
    email: user.email,
    avatarUrl: user.avatarUrl,
    phone: user.phone,
    referralCode: user.referralCode,
    joinedAt: user.joinedAt,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'avatarUrl': avatarUrl,
    'phone': phone,
    'referralCode': referralCode,
    'joinedAt': joinedAt.toIso8601String(),
  };
}
