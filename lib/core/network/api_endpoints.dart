/// Every backend path, relative to `ApiConfig.baseUrl`.
///
/// These are placeholders until the backend contract is final: change a path
/// here and every data source picks it up.
abstract final class ApiEndpoints {
  // Auth
  static const googleLogin = '/auth/google';
  static const refreshToken = '/auth/refresh';
  static const logout = '/auth/logout';

  // User
  static const currentUser = '/users/me';
  static const profileStats = '/users/me/stats';

  // Home
  static const banners = '/home/banners';
  static const earnOptions = '/home/earn-options';

  // Wallet
  static const wallet = '/wallet';
  static const transactions = '/wallet/transactions';
  static const redeemOptions = '/wallet/redeem-options';
  static const redeem = '/wallet/redeem';

  // Rewards
  static const dailyRewards = '/rewards/daily';
  static const rewardSummary = '/rewards/summary';
  static const rewardHistory = '/rewards/history';
  static const checkIn = '/rewards/check-in';
  static const checkInClaim = '/rewards/check-in/claim';
  static const spinWheel = '/rewards/spin-wheel';
  static const spinWheelSpin = '/rewards/spin-wheel/spin';
  static const scratchCard = '/rewards/scratch-card';
  static String scratchCardReveal(String cardId) =>
      '/rewards/scratch-card/$cardId/reveal';
  static const captcha = '/rewards/captcha';
  static String captchaSubmit(String challengeId) =>
      '/rewards/captcha/$challengeId/submit';

  // Leaderboard
  static const leaderboard = '/leaderboard';

  // Notifications
  static const notifications = '/notifications';
  static String notificationRead(String id) => '/notifications/$id/read';
  static const notificationsReadAll = '/notifications/read-all';
  static const notificationsUnreadCount = '/notifications/unread-count';

  // Referral
  static const referral = '/referral';

  // Support
  static const support = '/support';

  // Articles
  static const articles = '/articles';
  static const articleCategories = '/articles/categories';
  static String article(String id) => '/articles/$id';
  static String articleClaim(String id) => '/articles/$id/claim';
  static const readingSummary = '/articles/reading-summary';

  // Shopping
  static const merchants = '/shop/merchants';
  static const merchantCategories = '/shop/categories';
  static String merchant(String id) => '/shop/merchants/$id';
  static String merchantProducts(String merchantId) =>
      '/shop/merchants/$merchantId/products';

  // Quiz
  static const quizCategories = '/quiz/categories';
  static String quiz(String type) => '/quiz/$type';
  static String quizSubmit(String quizId) => '/quiz/$quizId/submit';
}
