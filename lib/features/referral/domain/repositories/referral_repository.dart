import '../entities/referral.dart';

abstract interface class ReferralRepository {
  Future<ReferralInfo> getReferralInfo();
}
