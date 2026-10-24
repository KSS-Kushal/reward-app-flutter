import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import 'app_network_image.dart';

/// Visual identity of a feature tile: an icon with its accent colour and,
/// optionally, a real illustration that replaces the icon once available.
@immutable
class FeatureVisual {
  const FeatureVisual({
    required this.icon,
    required this.color,
    this.assetPath,
    this.imageUrl,
  });

  final IconData icon;
  final Color color;

  /// Local illustration (e.g. `AppAssets.spinWheel`). Takes precedence.
  final String? assetPath;

  /// Remote illustration delivered by the backend.
  final String? imageUrl;
}

/// Illustration slot used by reward, earn and quiz cards.
///
/// Renders [FeatureVisual.assetPath] or [FeatureVisual.imageUrl] when set,
/// otherwise a soft "3D-like" icon badge in the feature's accent colour.
class FeatureIcon extends StatelessWidget {
  const FeatureIcon({required this.visual, this.size = 56, super.key});

  final FeatureVisual visual;
  final double size;

  @override
  Widget build(BuildContext context) {
    final asset = visual.assetPath;
    if (asset != null) {
      return Image.asset(asset, width: size, height: size, fit: BoxFit.contain);
    }
    final url = visual.imageUrl;
    if (url != null) {
      return AppNetworkImage(
        url: url,
        width: size,
        height: size,
        fit: BoxFit.contain,
        fallback: _IconBadge(visual: visual, size: size),
      );
    }
    return _IconBadge(visual: visual, size: size);
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.visual, required this.size});

  final FeatureVisual visual;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = visual.color;
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.lerp(color, Colors.white, 0.55)!,
              Color.lerp(color, Colors.white, 0.15)!,
            ],
          ),
          border: Border.all(color: AppColors.surface, width: size * 0.05),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.35),
              blurRadius: size * 0.2,
              offset: Offset(0, size * 0.08),
            ),
          ],
        ),
        child: Icon(visual.icon, color: Colors.white, size: size * 0.52),
      ),
    );
  }
}
