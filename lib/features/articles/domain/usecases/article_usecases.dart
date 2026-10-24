import '../../../../shared/models/paginated_list.dart';
import '../entities/article.dart';
import '../repositories/article_repository.dart';

class GetArticleCategories {
  const GetArticleCategories(this._repository);
  final ArticleRepository _repository;

  Future<List<ArticleCategory>> call() => _repository.getCategories();
}

class GetArticles {
  const GetArticles(this._repository);
  final ArticleRepository _repository;

  Future<PaginatedList<Article>> call({
    String? categoryId,
    bool rewardableOnly = false,
    int page = 1,
  }) => _repository.getArticles(
    categoryId: categoryId,
    rewardableOnly: rewardableOnly,
    page: page,
  );
}

class GetArticle {
  const GetArticle(this._repository);
  final ArticleRepository _repository;

  Future<Article> call(String id) => _repository.getArticle(id);
}

class GetReadingSummary {
  const GetReadingSummary(this._repository);
  final ArticleRepository _repository;

  Future<ReadingSummary> call() => _repository.getReadingSummary();
}

class ClaimArticleReward {
  const ClaimArticleReward(this._repository);
  final ArticleRepository _repository;

  Future<ArticleRewardResult> call({
    required String articleId,
    required int secondsRead,
  }) => _repository.claimReward(articleId: articleId, secondsRead: secondsRead);
}
