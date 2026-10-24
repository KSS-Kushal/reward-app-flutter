import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/core_providers.dart';
import '../data/datasources/home_mock_data_source.dart';
import '../data/datasources/home_remote_data_source.dart';
import '../data/repositories/home_repository_impl.dart';
import '../domain/repositories/home_repository.dart';
import '../domain/usecases/home_usecases.dart';

final homeRemoteDataSourceProvider = Provider<HomeRemoteDataSource>((ref) {
  if (ref.watch(useMockApiProvider)) return const HomeMockDataSource();
  return HomeApiDataSource(ref.watch(apiClientProvider));
});

final homeRepositoryProvider = Provider<HomeRepository>(
  (ref) => HomeRepositoryImpl(ref.watch(homeRemoteDataSourceProvider)),
);

final getHomeBannersProvider = Provider(
  (ref) => GetHomeBanners(ref.watch(homeRepositoryProvider)),
);
final getEarnOptionsProvider = Provider(
  (ref) => GetEarnOptions(ref.watch(homeRepositoryProvider)),
);
