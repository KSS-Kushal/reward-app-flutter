import 'dart:convert';

import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/storage/storage_keys.dart';
import '../../../../core/storage/token_storage.dart';
import '../../../../core/utils/app_logger.dart';
import '../models/user_model.dart';

/// Persists the session (tokens + last known user) in secure storage.
class AuthLocalDataSource {
  const AuthLocalDataSource({
    required this._tokenStorage,
    required this._secureStorage,
  });

  final TokenStorage _tokenStorage;
  final SecureStorageService _secureStorage;

  Future<bool> hasSession() => _tokenStorage.hasSession();

  Future<void> saveSession({
    required String accessToken,
    required UserModel user,
    String? refreshToken,
  }) async {
    await _tokenStorage.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
    await cacheUser(user);
  }

  Future<void> cacheUser(UserModel user) =>
      _secureStorage.write(StorageKeys.cachedUser, jsonEncode(user.toJson()));

  Future<UserModel?> readCachedUser() async {
    final raw = await _secureStorage.read(StorageKeys.cachedUser);
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return UserModel.fromJson(decoded);
    } on FormatException catch (error) {
      AppLogger.warning('Discarding corrupt cached user', error: error);
    }
    return null;
  }

  Future<void> clear() => _tokenStorage.clear();
}
