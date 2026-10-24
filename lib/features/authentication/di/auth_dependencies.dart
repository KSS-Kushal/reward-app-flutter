import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/config/app_config.dart';
import '../../../core/di/core_providers.dart';
import '../data/datasources/auth_local_data_source.dart';
import '../data/datasources/auth_mock_data_source.dart';
import '../data/datasources/auth_remote_data_source.dart';
import '../data/datasources/google_auth_service.dart';
import '../data/datasources/mock_user_store.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/usecases/auth_usecases.dart';

/// Shared in-memory "users table" for every mock data source.
final mockUserStoreProvider = Provider<MockUserStore>((ref) => MockUserStore());

final googleAuthServiceProvider = Provider<GoogleAuthService>(
  (ref) => GoogleSignInService(serverClientId: AppConfig.googleServerClientId),
);

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  if (ref.watch(useMockApiProvider)) {
    return AuthMockDataSource(
      ref.watch(mockUserStoreProvider),
      persistedUser: ref.watch(authLocalDataSourceProvider).readCachedUser,
    );
  }
  return AuthApiDataSource(ref.watch(apiClientProvider));
});

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>(
  (ref) => AuthLocalDataSource(
    tokenStorage: ref.watch(tokenStorageProvider),
    secureStorage: ref.watch(secureStorageProvider),
  ),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(
    googleAuthService: ref.watch(googleAuthServiceProvider),
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
    localDataSource: ref.watch(authLocalDataSourceProvider),
  ),
);

final signInWithGoogleProvider = Provider(
  (ref) => SignInWithGoogle(ref.watch(authRepositoryProvider)),
);
final signInAsDemoUserProvider = Provider(
  (ref) => SignInAsDemoUser(ref.watch(authRepositoryProvider)),
);
final restoreSessionProvider = Provider(
  (ref) => RestoreSession(ref.watch(authRepositoryProvider)),
);
final signOutProvider = Provider(
  (ref) => SignOut(ref.watch(authRepositoryProvider)),
);
