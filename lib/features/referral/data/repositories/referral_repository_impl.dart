import '../../domain/entities/referral.dart';
import '../../domain/repositories/referral_repository.dart';
import '../datasources/referral_remote_data_source.dart';

class ReferralRepositoryImpl implements ReferralRepository {
  const ReferralRepositoryImpl(this._remote);

  final ReferralRemoteDataSource _remote;

  @override
  Future<ReferralInfo> getReferralInfo() => _remote.getReferralInfo();
}
