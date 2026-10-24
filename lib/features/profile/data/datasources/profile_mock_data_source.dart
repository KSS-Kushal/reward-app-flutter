import '../../../../core/mock/mock_latency.dart';
import '../../../authentication/data/datasources/mock_user_store.dart';
import '../../../authentication/data/models/user_model.dart';
import '../../../wallet/data/datasources/mock_wallet_ledger.dart';
import '../models/profile_stats_model.dart';
import 'profile_remote_data_source.dart';

class ProfileMockDataSource implements ProfileRemoteDataSource {
  const ProfileMockDataSource({
    required this._userStore,
    required this._ledger,
  });

  final MockUserStore _userStore;
  final MockWalletLedger _ledger;

  @override
  Future<ProfileStatsModel> getStats() async {
    await MockLatency.simulate();
    return ProfileStatsModel(
      totalEarned: _ledger.wallet.totalEarned,
      currentStreak: 2,
      rank: 42,
      referrals: 2,
    );
  }

  @override
  Future<UserModel> updateProfile({required String name, String? phone}) async {
    await MockLatency.simulate();
    final current = _userStore.currentUser ?? MockUserStore.demoUser;
    final updated = UserModel(
      id: current.id,
      name: name,
      email: current.email,
      avatarUrl: current.avatarUrl,
      phone: phone,
      referralCode: current.referralCode,
      joinedAt: current.joinedAt,
    );
    _userStore.currentUser = updated;
    return updated;
  }
}
