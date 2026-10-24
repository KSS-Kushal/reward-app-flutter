import '../../../../shared/models/paginated_list.dart';
import '../entities/article.dart';

abstract interface class ArticleRepository {
  Future<List<ArticleCategory>> getCategories();

  Future<PaginatedList<Article>> getArticles({
    String? categoryId,
    bool rewardableOnly = false,
    int page = 1,
    int pageSize = 10,
  });

  Future<Article> getArticle(String id);

  Future<ReadingSummary> getReadingSummary();

  /// Requests the reading reward. The backend decides eligibility using its
  /// own session tracking; [secondsRead] is a hint only.
  Future<ArticleRewardResult> claimReward({
    required String articleId,
    required int secondsRead,
  });
}
