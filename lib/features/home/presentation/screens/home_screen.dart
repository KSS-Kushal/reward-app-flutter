import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/config/app_config.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/services/external_link_service.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../authentication/presentation/providers/auth_controller.dart';
import '../../../notifications/presentation/providers/notification_providers.dart';
import '../../../wallet/presentation/providers/wallet_providers.dart';
import '../../domain/entities/promo_banner.dart';
import '../providers/home_providers.dart';
import '../widgets/home_banner_carousel.dart';
import '../widgets/home_sections.dart';
import '../widgets/profile_header.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: RefreshIndicator(
          onRefresh: () => refreshHome(ref),
          edgeOffset: MediaQuery.paddingOf(context).top,
          child: const CustomScrollView(
            physics: AlwaysScrollableScrollPhysics(
              parent: ClampingScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(child: _HomeHeader()),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.page,
                  0,
                  AppSpacing.page,
                  AppSizes.bottomNavClearance,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate.fixed([
                    QuickActionsRow(),
                    SizedBox(height: AppSpacing.xxl),
                    DailyRewardsSection(),
                    SizedBox(height: AppSpacing.section),
                    EarnMoreSection(),
                    SizedBox(height: AppSpacing.section),
                    QuizZoneSection(),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dark green area with the profile header and banner carousel. Its bottom
/// edge draws the rounded top of the light content sheet.
class _HomeHeader extends ConsumerWidget {
  const _HomeHeader();

  void _onBannerTap(BuildContext context, WidgetRef ref, PromoBanner banner) {
    final route = banner.actionRoute;
    if (route != null) {
      context.push(route);
    } else if (banner.actionUrl != null) {
      ref.read(externalLinkServiceProvider).openUrl(banner.actionUrl!);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final coins = ref.watch(walletProvider.select((w) => w.value?.balance));
    final hasUnread = ref.watch(
      unreadNotificationCountProvider.select((c) => (c.value ?? 0) > 0),
    );
    final banners = ref.watch(homeBannersProvider);

    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppColors.headerGradient),
      child: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.page,
                AppSpacing.md,
                AppSpacing.page,
                AppSpacing.lg,
              ),
              child: ProfileHeader(
                name: user?.firstName ?? '',
                avatarUrl: user?.avatarUrl,
                greeting: 'Welcome to ${AppConfig.appName}',
                coins: coins,
                hasUnreadNotifications: hasUnread,
                onAvatarTap: () => context.go(AppRoutes.profile),
                onNotificationsTap: () => context.push(AppRoutes.notifications),
                onCoinsTap: () => context.go(AppRoutes.wallet),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
            child: banners.when(
              data: (data) => HomeBannerCarousel(
                banners: data,
                onBannerTap: (banner) => _onBannerTap(context, ref, banner),
              ),
              loading: () =>
                  HomeBannerCarousel(banners: null, onBannerTap: (_) {}),
              error: (error, _) => AppErrorView(
                error: error,
                compact: true,
                onRetry: () => ref.invalidate(homeBannersProvider),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Container(
            height: AppRadius.sheet + AppSpacing.sm,
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius: AppRadius.sheetTop,
            ),
          ),
        ],
      ),
    );
  }
}
