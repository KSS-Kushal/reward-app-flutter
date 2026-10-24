import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/color_utils.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../domain/entities/promo_banner.dart';

/// Auto-scrolling banner carousel with page indicator.
///
/// Pass `banners: null` to show the loading skeleton. An empty list
/// collapses the carousel entirely.
class HomeBannerCarousel extends StatefulWidget {
  const HomeBannerCarousel({
    required this.banners,
    required this.onBannerTap,
    this.autoScroll = true,
    super.key,
  });

  final List<PromoBanner>? banners;
  final ValueChanged<PromoBanner> onBannerTap;
  final bool autoScroll;

  /// Width / height ratio of the Figma banner.
  static const aspectRatio = 2.25;

  @override
  State<HomeBannerCarousel> createState() => _HomeBannerCarouselState();
}

class _HomeBannerCarouselState extends State<HomeBannerCarousel> {
  final _controller = PageController();
  Timer? _timer;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _restartTimer();
  }

  @override
  void didUpdateWidget(covariant HomeBannerCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.banners?.length != widget.banners?.length) _restartTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _restartTimer() {
    _timer?.cancel();
    final count = widget.banners?.length ?? 0;
    if (!widget.autoScroll || count < 2) return;
    _timer = Timer.periodic(AppDurations.bannerAutoScroll, (_) {
      if (!_controller.hasClients) return;
      final next = (_page + 1) % count;
      _controller.animateToPage(
        next,
        duration: AppDurations.slow,
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final banners = widget.banners;
    if (banners == null) {
      return const AspectRatio(
        aspectRatio: HomeBannerCarousel.aspectRatio,
        child: SkeletonBox(borderRadius: AppRadius.xlAll),
      );
    }
    if (banners.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        AspectRatio(
          aspectRatio: HomeBannerCarousel.aspectRatio,
          child: NotificationListener<ScrollStartNotification>(
            // Pause auto-scroll while the user drags.
            onNotification: (notification) {
              if (notification.dragDetails != null) _restartTimer();
              return false;
            },
            child: PageView.builder(
              controller: _controller,
              itemCount: banners.length,
              onPageChanged: (page) => setState(() => _page = page),
              itemBuilder: (context, index) => _BannerTile(
                banner: banners[index],
                onTap: () => widget.onBannerTap(banners[index]),
              ),
            ),
          ),
        ),
        if (banners.length > 1) ...[
          const SizedBox(height: AppSpacing.md),
          _PageIndicator(count: banners.length, current: _page),
        ],
      ],
    );
  }
}

class _BannerTile extends StatelessWidget {
  const _BannerTile({required this.banner, required this.onTap});

  final PromoBanner banner;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = banner.gradientHex.map(colorFromHex).toList();
    return Semantics(
      button: true,
      label: banner.title,
      excludeSemantics: true,
      child: ClipRRect(
        borderRadius: AppRadius.xlAll,
        child: Material(
          child: InkWell(
            onTap: onTap,
            child: Ink(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: colors.length >= 2
                      ? colors
                      : [colors.first, colors.first],
                ),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (banner.imageUrl != null)
                    AppNetworkImage(
                      url: banner.imageUrl,
                      fallback: _BannerText(banner: banner),
                    )
                  else
                    _BannerText(banner: banner),
                  if (banner.tag != null)
                    Positioned(top: 0, left: 0, child: _Tag(text: banner.tag!)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Text layout used when a banner has no artwork.
class _BannerText extends StatelessWidget {
  const _BannerText({required this.banner});

  final PromoBanner banner;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xxl,
        AppSpacing.xl,
        AppSpacing.lg,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  banner.title.toUpperCase(),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.titleLarge.copyWith(
                    color: const Color(0xFF16206B),
                    fontWeight: FontWeight.w700,
                    height: 1.15,
                  ),
                ),
                if (banner.subtitle != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    banner.subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: const Color(0xFF16206B),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Icon(
            Icons.card_giftcard_rounded,
            size: 64,
            color: const Color(0xFF16206B).withValues(alpha: 0.15),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFFFD43B),
        borderRadius: BorderRadius.only(bottomRight: Radius.circular(14)),
      ),
      child: Text(
        text,
        style: AppTextStyles.titleMedium.copyWith(color: AppColors.error),
      ),
    );
  }
}

class _PageIndicator extends StatelessWidget {
  const _PageIndicator({required this.count, required this.current});

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Banner ${current + 1} of $count',
      excludeSemantics: true,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < count; i++)
            AnimatedContainer(
              duration: AppDurations.medium,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i == current
                    ? const Color(0xFF22C55E)
                    : Colors.white.withValues(alpha: 0.7),
              ),
            ),
        ],
      ),
    );
  }
}
