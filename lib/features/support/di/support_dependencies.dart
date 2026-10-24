import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/core_providers.dart';
import '../data/datasources/support_mock_data_source.dart';
import '../data/datasources/support_remote_data_source.dart';
import '../data/repositories/support_repository_impl.dart';
import '../domain/repositories/support_repository.dart';
import '../domain/usecases/support_usecases.dart';

final supportRemoteDataSourceProvider = Provider<SupportRemoteDataSource>((
  ref,
) {
  if (ref.watch(useMockApiProvider)) return const SupportMockDataSource();
  return SupportApiDataSource(ref.watch(apiClientProvider));
});

final supportRepositoryProvider = Provider<SupportRepository>(
  (ref) => SupportRepositoryImpl(ref.watch(supportRemoteDataSourceProvider)),
);

final getSupportInfoProvider = Provider(
  (ref) => GetSupportInfo(ref.watch(supportRepositoryProvider)),
);
