import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/core_providers.dart';
import '../../wallet/di/wallet_dependencies.dart';
import '../data/datasources/article_mock_data_source.dart';
import '../data/datasources/article_remote_data_source.dart';
import '../data/repositories/article_repository_impl.dart';
import '../domain/repositories/article_repository.dart';
import '../domain/usecases/article_usecases.dart';

final articleRemoteDataSourceProvider = Provider<ArticleRemoteDataSource>((
  ref,
) {
  if (ref.watch(useMockApiProvider)) {
    return ArticleMockDataSource(ref.watch(mockWalletLedgerProvider));
  }
  return ArticleApiDataSource(ref.watch(apiClientProvider));
});

final articleRepositoryProvider = Provider<ArticleRepository>(
  (ref) => ArticleRepositoryImpl(ref.watch(articleRemoteDataSourceProvider)),
);

final getArticleCategoriesProvider = Provider(
  (ref) => GetArticleCategories(ref.watch(articleRepositoryProvider)),
);
final getArticlesProvider = Provider(
  (ref) => GetArticles(ref.watch(articleRepositoryProvider)),
);
final getArticleProvider = Provider(
  (ref) => GetArticle(ref.watch(articleRepositoryProvider)),
);
final getReadingSummaryProvider = Provider(
  (ref) => GetReadingSummary(ref.watch(articleRepositoryProvider)),
);
final claimArticleRewardProvider = Provider(
  (ref) => ClaimArticleReward(ref.watch(articleRepositoryProvider)),
);
