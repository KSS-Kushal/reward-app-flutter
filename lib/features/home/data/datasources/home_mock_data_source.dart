import '../../../../core/mock/mock_latency.dart';
import '../../domain/entities/earn_option.dart';
import '../models/home_models.dart';
import 'home_remote_data_source.dart';

class HomeMockDataSource implements HomeRemoteDataSource {
  const HomeMockDataSource();

  @override
  Future<List<PromoBannerModel>> getBanners() async {
    await MockLatency.simulate();
    return const [
      PromoBannerModel(
        id: 'banner_follow',
        title: 'Stay connected & stay updated',
        subtitle: 'Follow us for exclusive bonus codes',
        tag: 'Ad',
        actionUrl: 'https://x.com/kavodnik_app',
        gradientHex: ['#E3F2FF', '#B9D9FA'],
      ),
      PromoBannerModel(
        id: 'banner_spin',
        title: 'Spin & win up to 100 coins',
        subtitle: '3 free spins every day',
        actionRoute: '/spin-wheel',
        gradientHex: ['#EDE9FE', '#C9BCF7'],
      ),
      PromoBannerModel(
        id: 'banner_invite',
        title: 'Invite friends, earn 250 coins',
        subtitle: 'For every friend who joins',
        actionRoute: '/invite',
        gradientHex: ['#FFEDE5', '#FFC9B3'],
      ),
    ];
  }

  @override
  Future<List<EarnOptionModel>> getEarnOptions() async {
    await MockLatency.simulate();
    return const [
      EarnOptionModel(
        id: 'earn_read',
        type: EarnOptionType.readAndEarn,
        title: 'Read & Earn',
        subtitle: 'Read articles and earn coins',
      ),
      EarnOptionModel(
        id: 'earn_shop',
        type: EarnOptionType.shopAndEarn,
        title: 'Shop & Earn',
        subtitle: 'Read Product and earn rewards',
      ),
      EarnOptionModel(
        id: 'earn_article',
        type: EarnOptionType.readArticle,
        title: 'Read Article',
        subtitle: 'Read articles and get rewarded',
      ),
    ];
  }
}
