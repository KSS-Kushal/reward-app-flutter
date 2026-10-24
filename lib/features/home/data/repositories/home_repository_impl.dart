import '../../domain/entities/earn_option.dart';
import '../../domain/entities/promo_banner.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_data_source.dart';

class HomeRepositoryImpl implements HomeRepository {
  const HomeRepositoryImpl(this._remote);

  final HomeRemoteDataSource _remote;

  @override
  Future<List<PromoBanner>> getBanners() => _remote.getBanners();

  @override
  Future<List<EarnOption>> getEarnOptions() => _remote.getEarnOptions();
}
