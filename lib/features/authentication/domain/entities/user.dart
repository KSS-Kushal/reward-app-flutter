import 'package:flutter/foundation.dart';

/// The signed-in user.
@immutable
class User {
  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.joinedAt,
    this.avatarUrl,
    this.phone,
    this.referralCode,
  });

  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final String? phone;
  final String? referralCode;
  final DateTime joinedAt;

  String get firstName {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'there';
    return trimmed.split(RegExp(r'\s+')).first;
  }

  User copyWith({String? name, String? avatarUrl, String? phone}) => User(
    id: id,
    name: name ?? this.name,
    email: email,
    avatarUrl: avatarUrl ?? this.avatarUrl,
    phone: phone ?? this.phone,
    referralCode: referralCode,
    joinedAt: joinedAt,
  );

  @override
  bool operator ==(Object other) =>
      other is User &&
      other.id == id &&
      other.name == name &&
      other.email == email &&
      other.avatarUrl == avatarUrl &&
      other.phone == phone &&
      other.referralCode == referralCode &&
      other.joinedAt == joinedAt;

  @override
  int get hashCode =>
      Object.hash(id, name, email, avatarUrl, phone, referralCode, joinedAt);
}
