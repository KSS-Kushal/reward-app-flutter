import '../../domain/entities/support_info.dart';
import '../../domain/repositories/support_repository.dart';
import '../datasources/support_remote_data_source.dart';

class SupportRepositoryImpl implements SupportRepository {
  const SupportRepositoryImpl(this._remote);

  final SupportRemoteDataSource _remote;

  @override
  Future<SupportInfo> getSupportInfo() => _remote.getSupportInfo();
}
