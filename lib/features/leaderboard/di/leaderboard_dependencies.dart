import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/core_providers.dart';
import '../../authentication/di/auth_dependencies.dart';
import '../data/datasources/leaderboard_mock_data_source.dart';
import '../data/datasources/leaderboard_remote_data_source.dart';
import '../data/repositories/leaderboard_repository_impl.dart';
import '../domain/repositories/leaderboard_repository.dart';
import '../domain/usecases/leaderboard_usecases.dart';

final leaderboardRemoteDataSourceProvider =
    Provider<LeaderboardRemoteDataSource>((ref) {
      if (ref.watch(useMockApiProvider)) {
        return LeaderboardMockDataSource(ref.watch(mockUserStoreProvider));
      }
      return LeaderboardApiDataSource(ref.watch(apiClientProvider));
    });

final leaderboardRepositoryProvider = Provider<LeaderboardRepository>(
  (ref) =>
      LeaderboardRepositoryImpl(ref.watch(leaderboardRemoteDataSourceProvider)),
);

final getLeaderboardProvider = Provider(
  (ref) => GetLeaderboard(ref.watch(leaderboardRepositoryProvider)),
);
