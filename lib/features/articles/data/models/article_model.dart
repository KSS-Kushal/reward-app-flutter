import '../../../../core/utils/json_reader.dart';
import '../../domain/entities/article.dart';

class ArticleCategoryModel extends ArticleCategory {
  const ArticleCategoryModel({required super.id, required super.name});

  factory ArticleCategoryModel.fromJson(Map<String, dynamic> json) =>
      ArticleCategoryModel(
        id: json.readString('id'),
        name: json.readString('name'),
      );

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

class ArticleModel extends Article {
  const ArticleModel({
    required super.id,
    required super.title,
    required super.summary,
    required super.content,
    required ArticleCategoryModel super.category,
    required super.author,
    required super.publishedAt,
    required super.readTimeMinutes,
    required super.rewardCoins,
    required super.requiredReadSeconds,
    required super.rewardStatus,
    super.imageUrl,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) => ArticleModel(
    id: json.readString('id'),
    title: json.readString('title'),
    summary: json.readString('summary'),
    content: json.readString('content'),
    category: ArticleCategoryModel.fromJson(json.readMap('category')),
    author: json.readString('author'),
    publishedAt: json.readDateTime('publishedAt'),
    readTimeMinutes: json.readInt('readTimeMinutes', fallback: 1),
    imageUrl: json.readStringOrNull('imageUrl'),
    rewardCoins: json.readInt('rewardCoins'),
    requiredReadSeconds: json.readInt('requiredReadSeconds', fallback: 30),
    rewardStatus: json.readEnum(
      'rewardStatus',
      ArticleRewardStatus.values,
      ArticleRewardStatus.unavailable,
    ),
  );

  ArticleModel copyWith({ArticleRewardStatus? rewardStatus}) => ArticleModel(
    id: id,
    title: title,
    summary: summary,
    content: content,
    category: category as ArticleCategoryModel,
    author: author,
    publishedAt: publishedAt,
    readTimeMinutes: readTimeMinutes,
    imageUrl: imageUrl,
    rewardCoins: rewardCoins,
    requiredReadSeconds: requiredReadSeconds,
    rewardStatus: rewardStatus ?? this.rewardStatus,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'summary': summary,
    'content': content,
    'category': (category as ArticleCategoryModel).toJson(),
    'author': author,
    'publishedAt': publishedAt.toIso8601String(),
    'readTimeMinutes': readTimeMinutes,
    'imageUrl': imageUrl,
    'rewardCoins': rewardCoins,
    'requiredReadSeconds': requiredReadSeconds,
    'rewardStatus': rewardStatus.name,
  };
}

class ReadingSummaryModel extends ReadingSummary {
  const ReadingSummaryModel({
    required super.articlesReadToday,
    required super.dailyLimit,
    required super.coinsEarnedToday,
  });

  factory ReadingSummaryModel.fromJson(Map<String, dynamic> json) =>
      ReadingSummaryModel(
        articlesReadToday: json.readInt('articlesReadToday'),
        dailyLimit: json.readInt('dailyLimit'),
        coinsEarnedToday: json.readInt('coinsEarnedToday'),
      );
}

class ArticleRewardResultModel extends ArticleRewardResult {
  const ArticleRewardResultModel({
    required super.coinsEarned,
    required super.message,
  });

  factory ArticleRewardResultModel.fromJson(Map<String, dynamic> json) =>
      ArticleRewardResultModel(
        coinsEarned: json.readInt('coinsEarned'),
        message: json.readString('message'),
      );
}
