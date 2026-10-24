import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../../../../shared/models/paginated_list.dart';
import '../models/article_model.dart';

abstract interface class ArticleRemoteDataSource {
  Future<List<ArticleCategoryModel>> getCategories();
  Future<PaginatedList<ArticleModel>> getArticles({
    required int page,
    required int pageSize,
    String? categoryId,
    bool rewardableOnly = false,
  });
  Future<ArticleModel> getArticle(String id);
  Future<ReadingSummaryModel> getReadingSummary();
  Future<ArticleRewardResultModel> claimReward({
    required String articleId,
    required int secondsRead,
  });
}

class ArticleApiDataSource implements ArticleRemoteDataSource {
  const ArticleApiDataSource(this._client);

  final ApiClient _client;

  @override
  Future<List<ArticleCategoryModel>> getCategories() => _client.get(
    ApiEndpoints.articleCategories,
    parser: (data) =>
        ApiResponse.asList(data)
            .map(ArticleCategoryModel.fromJson)
            .toList(growable: false),
  );

  @override
  Future<PaginatedList<ArticleModel>> getArticles({
    required int page,
    required int pageSize,
    String? categoryId,
    bool rewardableOnly = false,
  }) => _client.get(
    ApiEndpoints.articles,
    queryParameters: {
      'page': page,
      'limit': pageSize,
      'categoryId': ?categoryId,
      if (rewardableOnly) 'rewardable': true,
    },
    parser: (data) => PaginatedList.fromJson(
      ApiResponse.asObject(data),
      ArticleModel.fromJson,
    ),
  );

  @override
  Future<ArticleModel> getArticle(String id) => _client.get(
    ApiEndpoints.article(id),
    parser: (data) => ArticleModel.fromJson(ApiResponse.asObject(data)),
  );

  @override
  Future<ReadingSummaryModel> getReadingSummary() => _client.get(
    ApiEndpoints.readingSummary,
    parser: (data) => ReadingSummaryModel.fromJson(ApiResponse.asObject(data)),
  );

  @override
  Future<ArticleRewardResultModel> claimReward({
    required String articleId,
    required int secondsRead,
  }) => _client.post(
    ApiEndpoints.articleClaim(articleId),
    body: {'secondsRead': secondsRead},
    parser: (data) =>
        ArticleRewardResultModel.fromJson(ApiResponse.asObject(data)),
  );
}
