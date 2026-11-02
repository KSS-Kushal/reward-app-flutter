import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

import '../../../app/theme/app_colors.dart';
import '../../utils/app_logger.dart';
import '../ad_models.dart';
import '../ad_providers.dart';

/// Banner pinned to the bottom of a screen.
///
/// Networks alternate between screens; if the chosen one has no fill, the
/// other is tried, and when neither fills the slot collapses. The bottom
/// safe-area inset is always applied, so it can sit directly above the
/// system navigation bar.
class BannerAdSlot extends ConsumerStatefulWidget {
  const BannerAdSlot({required this.placement, super.key});

  /// The admin can switch banners off per placement.
  final AdPlacement placement;

  @override
  ConsumerState<BannerAdSlot> createState() => _BannerAdSlotState();
}

class _BannerAdSlotState extends ConsumerState<BannerAdSlot> {
  late final List<AdUnit> _units = ref
      .read(adServiceProvider)
      .bannerUnits(widget.placement);
  int _index = 0;

  void _onLoaded(AdUnit unit) =>
      ref.read(adServiceProvider).recordBannerShown(unit.network);

  void _onFailed() {
    if (mounted) setState(() => _index += 1);
  }

  @override
  Widget build(BuildContext context) {
    if (_index >= _units.length) {
      return const SafeArea(
        top: false,
        child: SizedBox(width: double.infinity),
      );
    }
    final unit = _units[_index];
    return ColoredBox(
      color: AppColors.surface,
      child: SafeArea(
        top: false,
        child: Center(
          heightFactor: 1,
          child: switch (unit.network) {
            AdNetwork.admob => _AdMobBanner(
              key: ValueKey(unit),
              unitId: unit.id,
              onLoaded: () => _onLoaded(unit),
              onFailed: _onFailed,
            ),
            AdNetwork.unity => UnityBannerAd(
              key: ValueKey(unit),
              placementId: unit.id,
              onLoad: (_) => _onLoaded(unit),
              onFailed: (placementId, error, message) {
                AppLogger.warning(
                  'Banner $placementId failed: $error $message',
                  tag: 'UnityAds',
                );
                _onFailed();
              },
            ),
          },
        ),
      ),
    );
  }
}

/// Anchored adaptive AdMob banner, as wide as the screen.
class _AdMobBanner extends StatefulWidget {
  const _AdMobBanner({
    required this.unitId,
    required this.onLoaded,
    required this.onFailed,
    super.key,
  });

  final String unitId;
  final VoidCallback onLoaded;
  final VoidCallback onFailed;

  @override
  State<_AdMobBanner> createState() => _AdMobBannerState();
}

class _AdMobBannerState extends State<_AdMobBanner> {
  BannerAd? _ad;
  bool _requested = false;
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_requested) return;
    _requested = true;
    _load(MediaQuery.sizeOf(context).width.truncate());
  }

  Future<void> _load(int width) async {
    final size =
        await AdSize.getLargeAnchoredAdaptiveBannerAdSize(width) ??
        AdSize.banner;
    if (!mounted) return;
    final ad = BannerAd(
      adUnitId: widget.unitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (!mounted) return;
          setState(() => _loaded = true);
          widget.onLoaded();
        },
        onAdFailedToLoad: (ad, error) {
          AppLogger.warning(
            'Banner failed: [${error.code}] ${error.message}',
            tag: 'AdMob',
          );
          ad.dispose();
          _ad = null;
          if (mounted) widget.onFailed();
        },
      ),
    );
    _ad = ad;
    await ad.load();
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
    return SizedBox(
      width: ad.size.width.toDouble(),
      height: ad.size.height.toDouble(),
      child: AdWidget(ad: ad),
    );
  }
}
