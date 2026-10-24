import '../../../../core/errors/errors.dart';
import '../../../../core/mock/mock_latency.dart';
import '../../../../shared/models/paginated_list.dart';
import '../../../wallet/data/datasources/mock_wallet_ledger.dart';
import '../../../wallet/domain/entities/transaction.dart';
import '../../domain/entities/article.dart';
import '../models/article_model.dart';
import 'article_remote_data_source.dart';

class ArticleMockDataSource implements ArticleRemoteDataSource {
  ArticleMockDataSource(this._ledger, {DateTime? now}) {
    _articles = _seed(now ?? DateTime.now());
  }

  final MockWalletLedger _ledger;
  late List<ArticleModel> _articles;
  int _claimedToday = 0;
  int _coinsToday = 0;

  static const dailyLimit = 5;

  static const _finance = ArticleCategoryModel(id: 'finance', name: 'Finance');
  static const _tech = ArticleCategoryModel(id: 'tech', name: 'Technology');
  static const _health = ArticleCategoryModel(id: 'health', name: 'Health');
  static const _lifestyle = ArticleCategoryModel(
    id: 'lifestyle',
    name: 'Lifestyle',
  );
  static const _categories = [_finance, _tech, _health, _lifestyle];

  @override
  Future<List<ArticleCategoryModel>> getCategories() async {
    await MockLatency.simulate();
    return _categories;
  }

  @override
  Future<PaginatedList<ArticleModel>> getArticles({
    required int page,
    required int pageSize,
    String? categoryId,
    bool rewardableOnly = false,
  }) async {
    await MockLatency.simulate();
    final filtered = _articles
        .where((a) => categoryId == null || a.category.id == categoryId)
        .where((a) => !rewardableOnly || a.hasReward)
        .toList();
    final start = (page - 1) * pageSize;
    return PaginatedList(
      items: filtered.skip(start).take(pageSize).toList(growable: false),
      page: page,
      pageSize: pageSize,
      totalCount: filtered.length,
      hasMore: start + pageSize < filtered.length,
    );
  }

  @override
  Future<ArticleModel> getArticle(String id) async {
    await MockLatency.simulate();
    return _find(id);
  }

  @override
  Future<ReadingSummaryModel> getReadingSummary() async {
    await MockLatency.simulate();
    return ReadingSummaryModel(
      articlesReadToday: _claimedToday,
      dailyLimit: dailyLimit,
      coinsEarnedToday: _coinsToday,
    );
  }

  @override
  Future<ArticleRewardResultModel> claimReward({
    required String articleId,
    required int secondsRead,
  }) async {
    await MockLatency.simulate();
    final article = _find(articleId);
    if (!article.canEarn) {
      throw const ValidationException(
        message: 'This article reward has already been claimed.',
        code: 'already_claimed',
      );
    }
    if (_claimedToday >= dailyLimit) {
      throw const ValidationException(
        message: "You've reached today's reading limit. Come back tomorrow!",
        code: 'daily_limit',
      );
    }
    if (secondsRead < article.requiredReadSeconds) {
      throw ValidationException(
        message:
            'Keep reading! You need ${article.requiredReadSeconds} seconds '
            'to earn this reward.',
        code: 'not_enough_time',
      );
    }
    _articles = [
      for (final a in _articles)
        a.id == articleId
            ? a.copyWith(rewardStatus: ArticleRewardStatus.claimed)
            : a,
    ];
    _claimedToday += 1;
    _coinsToday += article.rewardCoins;
    _ledger.credit(
      source: TransactionSource.article,
      title: 'Read & Earn',
      amount: article.rewardCoins,
      description: article.title,
    );
    return ArticleRewardResultModel(
      coinsEarned: article.rewardCoins,
      message: 'Thanks for reading!',
    );
  }

  ArticleModel _find(String id) => _articles.firstWhere(
    (a) => a.id == id,
    orElse: () => throw const ServerException(
      message: 'This article is no longer available.',
      statusCode: 404,
    ),
  );

  static List<ArticleModel> _seed(DateTime now) {
    ArticleModel article(
      int index, {
      required String title,
      required String summary,
      required ArticleCategoryModel category,
      required int coins,
      int minutes = 3,
      ArticleRewardStatus status = ArticleRewardStatus.available,
    }) => ArticleModel(
      id: 'article_$index',
      title: title,
      summary: summary,
      content: _body(title, summary),
      category: category,
      author: const ['Kavodnik Team', 'Ananya Iyer', 'Rohit Menon'][index % 3],
      publishedAt: now.subtract(Duration(days: index, hours: index * 3)),
      readTimeMinutes: minutes,
      imageUrl: 'https://picsum.photos/seed/kavodnik$index/800/450',
      rewardCoins: coins,
      requiredReadSeconds: coins == 0 ? 0 : 20 + (index % 3) * 5,
      rewardStatus: coins == 0 ? ArticleRewardStatus.unavailable : status,
    );

    return [
      article(
        1,
        title: '5 simple habits to save money every month',
        summary: 'Small changes in your routine can add up to big savings.',
        category: _finance,
        coins: 20,
      ),
      article(
        2,
        title: 'How UPI changed the way India pays',
        summary: 'A quick look at the technology behind instant payments.',
        category: _tech,
        coins: 15,
        minutes: 4,
      ),
      article(
        3,
        title: 'A 10-minute morning stretch routine',
        summary: 'Wake up your body and feel energised all day.',
        category: _health,
        coins: 10,
      ),
      article(
        4,
        title: 'Budget travel: weekend trips under ₹5,000',
        summary: 'Plan memorable getaways without breaking the bank.',
        category: _lifestyle,
        coins: 15,
        status: ArticleRewardStatus.claimed,
      ),
      article(
        5,
        title: 'Understanding credit scores',
        summary: 'What affects your score and how to improve it.',
        category: _finance,
        coins: 20,
        minutes: 5,
      ),
      article(
        6,
        title: 'Keep your phone secure: 7 essential tips',
        summary: 'Protect your data and accounts from common threats.',
        category: _tech,
        coins: 10,
      ),
      article(
        7,
        title: 'Why sleep matters more than you think',
        summary: 'The science of rest and how to get better sleep.',
        category: _health,
        coins: 0,
        minutes: 6,
      ),
      article(
        8,
        title: 'Decluttering your home, one room at a time',
        summary: 'A calm, step-by-step approach to a tidier space.',
        category: _lifestyle,
        coins: 0,
      ),
    ];
  }

  static String _body(String title, String summary) => [
    summary,
    'Most people know what they should be doing, but turning good intentions '
        'into everyday habits is the hard part. The secret is to start small '
        'and make the new behaviour easy to repeat.',
    'Begin by noticing where you are today. Write down what you currently do, '
        'without judging it. Awareness alone often leads to better choices.',
    'Next, pick one tiny change and attach it to something you already do '
        'every day. Consistency matters far more than intensity, and small '
        'wins build the confidence you need for bigger ones.',
    'Track your progress for a few weeks. Seeing a streak grow is surprisingly '
        'motivating, and it helps you notice what works for you.',
    'Finally, be kind to yourself when you slip. Every expert was once a '
        'beginner, and progress is rarely a straight line. Keep going, and '
        '"$title" will soon feel like second nature.',
  ].join('\n\n');
}
