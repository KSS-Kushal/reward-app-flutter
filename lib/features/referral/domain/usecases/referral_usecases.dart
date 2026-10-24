import '../entities/referral.dart';
import '../repositories/referral_repository.dart';

class GetReferralInfo {
  const GetReferralInfo(this._repository);
  final ReferralRepository _repository;

  Future<ReferralInfo> call() => _repository.getReferralInfo();
}
