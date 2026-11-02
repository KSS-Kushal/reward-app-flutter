import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimensions.dart';
import '../../utils/app_logger.dart';
import '../ad_models.dart';
import '../ad_providers.dart';

/// Size of a native ad, using AdMob's built-in templates.
enum NativeAdSize {
  small(TemplateType.small, 120),
  medium(TemplateType.medium, 340);

  const NativeAdSize(this.template, this.height);

  final TemplateType template;
  final double height;

  /// The largest size that fits in [space], or `null` if none does.
  static NativeAdSize? thatFits(double space) {
    if (space >= medium.height) return medium;
    if (space >= small.height) return small;
    return null;
  }
}

/// An AdMob native ad. Collapses when ads are off or nothing loads.
class NativeAdSlot extends ConsumerStatefulWidget {
  const NativeAdSlot({
    required this.placement,
    this.size = NativeAdSize.medium,
    super.key,
  });

  /// The admin can switch native ads off per placement.
  final AdPlacement placement;
  final NativeAdSize size;

  @override
  ConsumerState<NativeAdSlot> createState() => _NativeAdSlotState();
}

class _NativeAdSlotState extends ConsumerState<NativeAdSlot> {
  NativeAd? _ad;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    final unit = ref.read(adServiceProvider).nativeUnit(widget.placement);
    if (unit == null) return;
    _ad = NativeAd(
      adUnitId: unit.id,
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _loaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          AppLogger.warning(
            'Native failed: [${error.code}] ${error.message}',
            tag: 'AdMob',
          );
          ad.dispose();
          _ad = null;
          if (mounted) setState(() {});
        },
      ),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: widget.size.template,
        mainBackgroundColor: AppColors.surface,
        cornerRadius: AppRadius.lg,
        callToActionTextStyle: NativeTemplateTextStyle(
          textColor: Colors.white,
          backgroundColor: AppColors.primary,
          style: NativeTemplateFontStyle.bold,
          size: 15,
        ),
      ),
    )..load();
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _ad;
    if (!_loaded || ad == null) return const SizedBox.shrink();
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: 320,
          maxWidth: 400,
          minHeight: widget.size.height,
          maxHeight: widget.size.height,
        ),
        child: AdWidget(ad: ad),
      ),
    );
  }
}

/// Last sliver of a scroll view: fills the empty space left below the
/// content with a native ad, choosing the size that fits. Shows nothing when
/// the content already fills the screen.
///
/// The size is sticky: it only ever shrinks (when the content grows), so a
/// loaded ad isn't reloaded each time the content above changes, e.g. the
/// captcha form ↔ countdown. The keyboard doesn't count as lost space.
class AdaptiveNativeAdSliver extends StatefulWidget {
  const AdaptiveNativeAdSliver({
    required this.placement,
    this.padding = const EdgeInsets.fromLTRB(
      AppSpacing.page,
      AppSpacing.lg,
      AppSpacing.page,
      AppSpacing.lg,
    ),
    super.key,
  });

  final AdPlacement placement;
  final EdgeInsets padding;

  @override
  State<AdaptiveNativeAdSliver> createState() => _AdaptiveNativeAdSliverState();
}

class _AdaptiveNativeAdSliverState extends State<AdaptiveNativeAdSliver> {
  NativeAdSize? _size;

  /// Keeps the current size while it fits; picks a new one otherwise.
  NativeAdSize? _sizeFor(double space) {
    final fits = NativeAdSize.thatFits(space);
    final current = _size;
    if (current == null || fits == null || fits.height < current.height) {
      _size = fits;
    }
    return _size;
  }

  @override
  Widget build(BuildContext context) {
    final padding = widget.padding;
    // The Scaffold shrinks the viewport while the keyboard is open; add the
    // keyboard back so focusing a text field doesn't swap the ad.
    final keyboard = MediaQueryData.fromView(View.of(context))
        .viewInsets
        .bottom;
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        // Uses the content's total extent, not the scroll position, so the
        // choice stays stable while scrolling.
        final empty =
            constraints.viewportMainAxisExtent +
            keyboard -
            constraints.precedingScrollExtent -
            padding.vertical;
        final size = _sizeFor(empty);
        return SliverToBoxAdapter(
          child: size == null
              ? const SizedBox.shrink()
              : Padding(
                  padding: padding,
                  child: NativeAdSlot(
                    key: ValueKey(size),
                    placement: widget.placement,
                    size: size,
                  ),
                ),
        );
      },
    );
  }
}
