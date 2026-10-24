import 'secure_storage_service.dart';
import 'storage_keys.dart';

/// Typed access to the session tokens kept in secure storage.
class TokenStorage {
  const TokenStorage(this._secureStorage);

  final SecureStorageService _secureStorage;

  Future<String?> readAccessToken() =>
      _secureStorage.read(StorageKeys.accessToken);

  Future<String?> readRefreshToken() =>
      _secureStorage.read(StorageKeys.refreshToken);

  Future<bool> hasSession() async {
    final token = await readAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    await _secureStorage.write(StorageKeys.accessToken, accessToken);
    if (refreshToken != null) {
      await _secureStorage.write(StorageKeys.refreshToken, refreshToken);
    }
  }

  Future<void> clear() async {
    await _secureStorage.delete(StorageKeys.accessToken);
    await _secureStorage.delete(StorageKeys.refreshToken);
    await _secureStorage.delete(StorageKeys.cachedUser);
  }
}
