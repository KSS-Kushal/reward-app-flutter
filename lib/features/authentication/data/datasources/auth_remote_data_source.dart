import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../models/auth_session_model.dart';
import '../models/user_model.dart';

/// Backend contract for authentication.
abstract interface class AuthRemoteDataSource {
  /// Exchanges a Google ID token for an application session.
  Future<AuthSessionModel> loginWithGoogle({required String idToken});

  Future<UserModel> getCurrentUser();

  Future<void> logout();
}

class AuthApiDataSource implements AuthRemoteDataSource {
  const AuthApiDataSource(this._client);

  final ApiClient _client;

  @override
  Future<AuthSessionModel> loginWithGoogle({required String idToken}) {
    return _client.post(
      ApiEndpoints.googleLogin,
      body: {'idToken': idToken},
      authenticated: false,
      parser: (data) => AuthSessionModel.fromJson(ApiResponse.asObject(data)),
    );
  }

  @override
  Future<UserModel> getCurrentUser() {
    return _client.get(
      ApiEndpoints.currentUser,
      parser: (data) => UserModel.fromJson(ApiResponse.asObject(data)),
    );
  }

  @override
  Future<void> logout() {
    return _client.post<void>(ApiEndpoints.logout, parser: (_) {});
  }
}
