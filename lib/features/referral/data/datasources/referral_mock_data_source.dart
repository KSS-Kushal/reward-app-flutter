import '../../../../core/mock/mock_latency.dart';
import '../../../authentication/data/datasources/mock_user_store.dart';
import '../../domain/entities/referral.dart';
import '../models/referral_model.dart';
import 'referral_remote_data_source.dart';

class ReferralMockDataSource implements ReferralRemoteDataSource {
  const ReferralMockDataSource(this._userStore);

  final MockUserStore _userStore;

  @override
  Future<ReferralInfoModel> getReferralInfo() async {
    await MockLatency.simulate();
    final code =
        _userStore.currentUser?.referralCode ??
        MockUserStore.demoUser.referralCode!;
    final link = 'https://kavodnik.app/invite/$code';
    final now = DateTime.now();
    return ReferralInfoModel(
      code: code,
      shareLink: link,
      shareMessage:
          'Join me on Kavodnik and earn rewards every day! Use my code '
          '$code to get 100 bonus coins: $link',
      rewardPerReferral: 250,
      totalInvited: 4,
      successfulReferrals: 2,
      totalEarned: 500,
      pendingCoins: 500,
      invitedUsers: [
        InvitedUserModel(
          id: 'ref_1',
          name: 'Aman Verma',
          avatarUrl: 'https://i.pravatar.cc/150?img=33',
          joinedAt: now.subtract(const Duration(days: 21)),
          status: ReferralStatus.completed,
          coinsEarned: 250,
        ),
        InvitedUserModel(
          id: 'ref_2',
          name: 'Neha Sharma',
          avatarUrl: 'https://i.pravatar.cc/150?img=45',
          joinedAt: now.subtract(const Duration(days: 12)),
          status: ReferralStatus.completed,
          coinsEarned: 250,
        ),
        InvitedUserModel(
          id: 'ref_3',
          name: 'Rahul Jain',
          joinedAt: now.subtract(const Duration(days: 3)),
          status: ReferralStatus.pending,
          coinsEarned: 0,
        ),
        InvitedUserModel(
          id: 'ref_4',
          name: 'Simran Kaur',
          joinedAt: now.subtract(const Duration(hours: 10)),
          status: ReferralStatus.pending,
          coinsEarned: 0,
        ),
      ],
    );
  }
}
