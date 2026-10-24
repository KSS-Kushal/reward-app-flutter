import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// Cached network image with consistent placeholder / error handling.
///
/// Decodes at the rendered size ([memCacheWidth]) to avoid holding
/// oversized bitmaps in memory.
class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.fallback,
    super.key,
  });

  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? fallback;

  @override
  Widget build(BuildContext context) {
    final placeholder =
        fallback ??
        const ColoredBox(
          color: AppColors.border,
          child: Center(
            child: Icon(Icons.image_outlined, color: AppColors.textTertiary),
          ),
        );

    final source = url;
    if (source == null || source.isEmpty) {
      return SizedBox(width: width, height: height, child: placeholder);
    }

    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    return CachedNetworkImage(
      imageUrl: source,
      width: width,
      height: height,
      fit: fit,
      memCacheWidth: width == null || !width!.isFinite
          ? null
          : (width! * pixelRatio).round(),
      placeholder: (_, _) => placeholder,
      errorWidget: (_, _, _) => placeholder,
    );
  }
}
