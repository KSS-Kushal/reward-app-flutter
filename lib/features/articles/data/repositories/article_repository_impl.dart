import '../../../../shared/models/paginated_list.dart';
import '../../domain/entities/article.dart';
import '../../domain/repositories/article_repository.dart';
import '../datasources/article_remote_data_source.dart';

class ArticleRepositoryImpl implements ArticleRepository {
  const ArticleRepositoryImpl(this._remote);

  final ArticleRemoteDataSource _remote;

  @override
  Future<List<ArticleCategory>> getCategories() => _remote.getCategories();

  @override
  Future<PaginatedList<Article>> getArticles({
    String? categoryId,
    bool rewardableOnly = false,
    int page = 1,
    int pageSize = 10,
  }) => _remote.getArticles(
    page: page,
    pageSize: pageSize,
    categoryId: categoryId,
    rewardableOnly: rewardableOnly,
  );

  @override
  Future<Article> getArticle(String id) => _remote.getArticle(id);

  @override
  Future<ReadingSummary> getReadingSummary() => _remote.getReadingSummary();

  @override
  Future<ArticleRewardResult> claimReward({
    required String articleId,
    required int secondsRead,
  }) => _remote.claimReward(articleId: articleId, secondsRead: secondsRead);
}
