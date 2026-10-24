import 'package:flutter_test/flutter_test.dart';
import 'package:kavodnik/features/articles/data/models/article_model.dart';
import 'package:kavodnik/features/articles/domain/entities/article.dart';
import 'package:kavodnik/features/authentication/data/models/auth_session_model.dart';
import 'package:kavodnik/features/authentication/data/models/user_model.dart';
import 'package:kavodnik/features/home/data/models/home_models.dart';
import 'package:kavodnik/features/leaderboard/data/models/leaderboard_model.dart';
import 'package:kavodnik/features/notifications/data/models/app_notification_model.dart';
import 'package:kavodnik/features/notifications/domain/entities/app_notification.dart';
import 'package:kavodnik/features/quiz/data/models/quiz_models.dart';
import 'package:kavodnik/features/quiz/domain/entities/quiz.dart';
import 'package:kavodnik/features/referral/data/models/referral_model.dart';
import 'package:kavodnik/features/rewards/data/models/reward_task_model.dart';
import 'package:kavodnik/features/rewards/domain/entities/reward_task.dart';
import 'package:kavodnik/features/shopping/data/models/merchant_model.dart';
import 'package:kavodnik/features/wallet/data/models/transaction_model.dart';
import 'package:kavodnik/features/wallet/data/models/wallet_model.dart';
import 'package:kavodnik/features/wallet/domain/entities/transaction.dart';
import 'package:kavodnik/shared/models/paginated_list.dart';

void main() {
  group('UserModel', () {
    final json = {
      'id': 'user_001',
      'name': 'Kushal',
      'email': 'user@example.com',
      'avatarUrl': null,
      'phone': '+91 90000 00000',
      'referralCode': 'KUSHAL1',
      'joinedAt': '2026-03-14T00:00:00.000',
    };

    test('round-trips through JSON', () {
      final user = UserModel.fromJson(json);
      expect(user.firstName, 'Kushal');
      expect(UserModel.fromJson(user.toJson()), user);
    });

    test('auth session parses tokens and nested user', () {
      final session = AuthSessionModel.fromJson({
        'accessToken': 'a',
        'refreshToken': 'r',
        'user': json,
      });
      expect(session.accessToken, 'a');
      expect(session.user.email, 'user@example.com');
    });
  });

  group('Wallet', () {
    test('tolerates numbers sent as strings and missing fields', () {
      final wallet = WalletModel.fromJson({
        'balance': '250',
        'totalEarned': 900,
      });
      expect(wallet.balance, 250);
      expect(wallet.pendingCoins, 0);
      expect(wallet.coinsPerCurrencyUnit, 100);
      expect(wallet.balanceInCurrency, 2.5);
    });

    test('transaction enums accept snake_case and unknown values', () {
      final tx = TransactionModel.fromJson({
        'id': 't1',
        'title': 'Spin',
        'amount': -50,
        'type': 'debit',
        'status': 'PENDING',
        'source': 'spin_wheel',
        'createdAt': '2026-10-01T10:00:00Z',
      });
      expect(tx.amount, 50);
      expect(tx.signedAmount, -50);
      expect(tx.status, TransactionStatus.pending);
      expect(tx.source, TransactionSource.spinWheel);

      final unknown = TransactionModel.fromJson({'source': 'lottery'});
      expect(unknown.source, TransactionSource.bonus);
      expect(TransactionModel.fromJson(tx.toJson()).signedAmount, -50);
    });
  });

  group('PaginatedList', () {
    Map<String, dynamic> page(Map<String, dynamic> pagination) => {
      'items': [
        {'id': 'n1', 'title': 'Hi', 'body': 'b', 'type': 'reward'},
      ],
      ...pagination,
    };

    test('parses the backend pagination object', () {
      final list = PaginatedList.fromJson(
        page({
          'currentPage': 2,
          'limit': 20,
          'totalItems': 57,
          'totalPages': 3,
          'isLast': false,
          'hasNext': true,
        }),
        AppNotificationModel.fromJson,
      );
      expect(list.items.single.type, NotificationType.reward);
      expect(list.page, 2);
      expect(list.pageSize, 20);
      expect(list.totalCount, 57);
      expect(list.hasMore, isTrue);
    });

    test('last page has no more items', () {
      final list = PaginatedList.fromJson(
        page({'currentPage': 3, 'limit': 20, 'isLast': true, 'hasNext': false}),
        AppNotificationModel.fromJson,
      );
      expect(list.hasMore, isFalse);
    });

    test('falls back to isLast, then totalPages', () {
      expect(
        PaginatedList.fromJson(
          page({'currentPage': 1, 'isLast': false}),
          AppNotificationModel.fromJson,
        ).hasMore,
        isTrue,
      );
      expect(
        PaginatedList.fromJson(
          page({'currentPage': 3, 'totalPages': 3}),
          AppNotificationModel.fromJson,
        ).hasMore,
        isFalse,
      );
    });
  });

  test('RewardTaskModel parses daily reward card data', () {
    final task = RewardTaskModel.fromJson({
      'id': 'task_spin',
      'type': 'spin_wheel',
      'title': 'Spin Wheel',
      'subtitle': 'Win up to 100 coins',
      'actionLabel': 'Spin',
      'rewardCoins': 100,
      'status': 'completed',
      'remainingAttempts': 0,
    });
    expect(task.type, RewardTaskType.spinWheel);
    expect(task.isCompleted, isTrue);
    expect(RewardTaskModel.fromJson(task.toJson()).title, 'Spin Wheel');
  });

  test('QuizModel never requires answers from the backend', () {
    final quiz = QuizModel.fromJson({
      'id': 'q1',
      'type': 'give_answer',
      'title': 'Give Answer',
      'rewardPerCorrect': 15,
      'questions': [
        {'id': 'a', 'text': 'Largest ocean?', 'answerType': 'text'},
      ],
    });
    expect(quiz.type, QuizType.giveAnswer);
    expect(quiz.isTimed, isFalse);
    expect(quiz.questions.single.answerType, QuizAnswerType.text);
    expect(const QuizAnswer(questionId: 'a', text: 'Pacific').toJson(), {
      'questionId': 'a',
      'text': 'Pacific',
    });
  });

  test('EarnOptionModel skips option types unknown to this app version', () {
    expect(
      EarnOptionModel.tryFromJson({'id': 'x', 'type': 'watch_video'}),
      isNull,
    );
    expect(
      EarnOptionModel.tryFromJson({'id': 'y', 'type': 'shop_and_earn'}),
      isNotNull,
    );
  });

  test('PromoBannerModel falls back to a default gradient', () {
    final banner = PromoBannerModel.fromJson({'id': 'b', 'title': 'Hello'});
    expect(banner.gradientHex, hasLength(2));
    expect(PromoBannerModel.fromJson(banner.toJson()).title, 'Hello');
  });

  test('Article, merchant, referral and leaderboard models parse', () {
    final article = ArticleModel.fromJson({
      'id': 'a1',
      'title': 'T',
      'category': {'id': 'c', 'name': 'Finance'},
      'rewardCoins': 10,
      'rewardStatus': 'available',
    });
    expect(article.canEarn, isTrue);
    expect(ArticleModel.fromJson(article.toJson()).category.name, 'Finance');
    expect(article.rewardStatus, ArticleRewardStatus.available);

    final merchant = MerchantModel.fromJson({
      'id': 'm',
      'name': 'Store',
      'category': {'id': 'f', 'name': 'Fashion'},
      'cashbackPercent': '6.5',
      'terms': ['one', 2],
      'offers': [
        {'id': 'o', 'title': '10% off', 'couponCode': 'SAVE10'},
      ],
    });
    expect(merchant.cashbackPercent, 6.5);
    expect(merchant.terms, ['one']);
    expect(merchant.offers.single.couponCode, 'SAVE10');

    final referral = ReferralInfoModel.fromJson({
      'code': 'ABC',
      'invitedUsers': [
        {'id': 'r', 'name': 'Aman', 'status': 'completed', 'coinsEarned': 250},
      ],
    });
    expect(referral.invitedUsers.single.coinsEarned, 250);

    final board = LeaderboardModel.fromJson({
      'period': 'all_time',
      'entries': [
        {'rank': 1, 'userId': 'u', 'name': 'Top', 'points': 900},
      ],
    });
    expect(board.podium.single.name, 'Top');
    expect(board.currentUser, isNull);
  });
}
