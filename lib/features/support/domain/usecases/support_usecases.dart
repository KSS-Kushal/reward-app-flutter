import '../entities/support_info.dart';
import '../repositories/support_repository.dart';

class GetSupportInfo {
  const GetSupportInfo(this._repository);
  final SupportRepository _repository;

  Future<SupportInfo> call() => _repository.getSupportInfo();
}
