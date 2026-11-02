import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/ads/ad_providers.dart';
import '../../core/ads/interstitial_route_observer.dart';

import '../../features/articles/presentation/screens/article_detail_screen.dart';
import '../../features/articles/presentation/screens/articles_screen.dart';
import '../../features/articles/presentation/screens/read_and_earn_screen.dart';
import '../../features/authentication/presentation/providers/auth_controller.dart';
import '../../features/authentication/presentation/providers/auth_state.dart';
import '../../features/authentication/presentation/screens/login_screen.dart';
import '../../features/authentication/presentation/screens/splash_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/leaderboard/presentation/screens/leaderboard_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/settings_screen.dart';
import '../../features/quiz/domain/entities/quiz.dart';
import '../../features/quiz/presentation/screens/quiz_screen.dart';
import '../../features/referral/presentation/screens/invite_screen.dart';
import '../../features/rewards/presentation/screens/captcha_screen.dart';
import '../../features/rewards/presentation/screens/daily_check_in_screen.dart';
import '../../features/rewards/presentation/screens/rewards_screen.dart';
import '../../features/rewards/presentation/screens/scratch_card_screen.dart';
import '../../features/rewards/presentation/screens/spin_wheel_screen.dart';
import '../../features/shopping/presentation/screens/merchant_products_screen.dart';
import '../../features/shopping/presentation/screens/shop_and_earn_screen.dart';
import '../../features/support/presentation/screens/contact_us_screen.dart';
import '../../features/wallet/presentation/screens/wallet_screen.dart';
import 'auth_redirect.dart';
import 'main_shell.dart';
import 'route_names.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

/// Shorthand for a full-screen route without parameters.
GoRoute _page(String path, Widget screen) =>
    GoRoute(path: path, builder: (context, state) => screen);

final appRouterProvider = Provider<GoRouter>((ref) {
  // Bridges Riverpod auth state to GoRouter's refreshListenable.
  final authState = ValueNotifier<AuthState>(ref.read(authControllerProvider));
  ref
    ..listen(authControllerProvider, (_, next) => authState.value = next)
    ..onDispose(authState.dispose);

  final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    refreshListenable: authState,
    observers: [
      // Occasional interstitial between screens, only for signed-in users.
      InterstitialRouteObserver(() {
        if (authState.value is AuthAuthenticated) {
          ref.read(adServiceProvider).onScreenChanged();
        }
      }),
    ],
    redirect: (context, state) =>
        authRedirect(authState.value, state.matchedLocation),
    routes: [
      _page(AppRoutes.splash, const SplashScreen()),
      _page(AppRoutes.login, const LoginScreen()),

      // Persistent bottom navigation.
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [_page(AppRoutes.home, const HomeScreen())],
          ),
          StatefulShellBranch(
            routes: [_page(AppRoutes.rewards, const RewardsScreen())],
          ),
          StatefulShellBranch(
            routes: [_page(AppRoutes.wallet, const WalletScreen())],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (context, state) => const ProfileScreen(),
                routes: [
                  GoRoute(
                    path: AppRoutes.editProfileSegment,
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => const EditProfileScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),

      // Full-screen pages pushed above the shell.
      _page(AppRoutes.settings, const SettingsScreen()),
      _page(AppRoutes.leaderboard, const LeaderboardScreen()),
      _page(AppRoutes.notifications, const NotificationsScreen()),
      _page(AppRoutes.invite, const InviteScreen()),
      _page(AppRoutes.contactUs, const ContactUsScreen()),
      _page(AppRoutes.dailyCheckIn, const DailyCheckInScreen()),
      _page(AppRoutes.spinWheel, const SpinWheelScreen()),
      _page(AppRoutes.scratchCard, const ScratchCardScreen()),
      _page(AppRoutes.captcha, const CaptchaScreen()),
      _page(AppRoutes.readAndEarn, const ReadAndEarnScreen()),
      GoRoute(
        path: AppRoutes.articles,
        builder: (context, state) => const ArticlesScreen(),
        routes: [
          GoRoute(
            path: AppRoutes.articleDetailSegment,
            builder: (context, state) => ArticleDetailScreen(
              articleId: state.pathParameters[AppRoutes.articleIdParam]!,
            ),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.shopAndEarn,
        builder: (context, state) => const ShopAndEarnScreen(),
        routes: [
          GoRoute(
            path: AppRoutes.merchantProductsSegment,
            builder: (context, state) => MerchantProductsScreen(
              merchantId: state.pathParameters[AppRoutes.merchantIdParam]!,
            ),
          ),
        ],
      ),
      _page(AppRoutes.dailyQuiz, const QuizScreen(type: QuizType.daily)),
      _page(AppRoutes.mathQuiz, const QuizScreen(type: QuizType.math)),
      _page(AppRoutes.giveAnswer, const QuizScreen(type: QuizType.giveAnswer)),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
