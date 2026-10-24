/// Every route path in the app. Never hardcode a path elsewhere.
abstract final class AppRoutes {
  // Entry
  static const splash = '/splash';
  static const login = '/login';

  // Bottom navigation tabs
  static const home = '/home';
  static const rewards = '/rewards';
  static const wallet = '/wallet';
  static const profile = '/profile';

  // Profile
  static const editProfile = '/profile/edit';
  static const editProfileSegment = 'edit';
  static const settings = '/settings';

  // Quick actions
  static const leaderboard = '/leaderboard';
  static const notifications = '/notifications';
  static const invite = '/invite';
  static const contactUs = '/contact-us';

  // Daily rewards
  static const dailyCheckIn = '/daily-checkin';
  static const spinWheel = '/spin-wheel';
  static const scratchCard = '/scratch-card';
  static const captcha = '/captcha';

  // Earn more
  static const readAndEarn = '/read-and-earn';
  static const shopAndEarn = '/shop-and-earn';
  static const merchantIdParam = 'merchantId';
  static const merchantProductsSegment = ':$merchantIdParam';

  /// Product list of one shopping platform.
  static String merchantProducts(String merchantId) =>
      '/shop-and-earn/$merchantId';
  static const articles = '/articles';
  static const articleIdParam = 'articleId';
  static const articleDetailSegment = ':$articleIdParam';
  static String articleDetail(String articleId) => '/articles/$articleId';

  // Quiz
  static const dailyQuiz = '/quiz/daily';
  static const mathQuiz = '/quiz/math';
  static const giveAnswer = '/quiz/give-answer';

  /// Routes reachable without a session.
  static const publicRoutes = {splash, login};
}
