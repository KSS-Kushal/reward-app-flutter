import '../entities/earn_option.dart';
import '../entities/promo_banner.dart';

abstract interface class HomeRepository {
  Future<List<PromoBanner>> getBanners();
  Future<List<EarnOption>> getEarnOptions();
}
