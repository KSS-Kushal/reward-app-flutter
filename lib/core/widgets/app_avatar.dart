import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import 'app_network_image.dart';

/// Circular user avatar; falls back to initials when there is no photo.
class AppAvatar extends StatelessWidget {
  const AppAvatar({
    required this.name,
    this.imageUrl,
    this.size = AppSizes.avatarMd,
    this.borderColor,
    this.borderWidth = 2,
    super.key,
  });

  final String name;
  final String? imageUrl;
  final double size;
  final Color? borderColor;
  final double borderWidth;

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (parts.isEmpty) return '?';
    return parts.take(2).map((p) => p[0].toUpperCase()).join();
  }

  @override
  Widget build(BuildContext context) {
    final initials = Container(
      color: AppColors.primaryLight,
      alignment: Alignment.center,
      child: Text(
        _initials,
        style: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
          fontSize: size * 0.36,
        ),
      ),
    );

    return Semantics(
      label: '$name profile picture',
      image: true,
      child: Container(
        width: size,
        height: size,
        padding: EdgeInsets.all(borderColor == null ? 0 : borderWidth),
        decoration: BoxDecoration(shape: BoxShape.circle, color: borderColor),
        child: ClipOval(
          child: AppNetworkImage(
            url: imageUrl,
            width: size,
            height: size,
            fallback: initials,
          ),
        ),
      ),
    );
  }
}
