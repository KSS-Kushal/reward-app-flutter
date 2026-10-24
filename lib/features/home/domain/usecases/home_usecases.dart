import '../entities/earn_option.dart';
import '../entities/promo_banner.dart';
import '../repositories/home_repository.dart';

class GetHomeBanners {
  const GetHomeBanners(this._repository);
  final HomeRepository _repository;

  Future<List<PromoBanner>> call() => _repository.getBanners();
}

class GetEarnOptions {
  const GetEarnOptions(this._repository);
  final HomeRepository _repository;

  Future<List<EarnOption>> call() => _repository.getEarnOptions();
}
