import 'package:flutter/material.dart';

/// Colour tokens taken from the Figma prototype.
abstract final class AppColors {
  // Brand
  static const primary = Color(0xFF0B8F55);
  static const primaryDark = Color(0xFF06472B);
  static const primaryLight = Color(0xFFD7F1E4);
  static const onPrimary = Colors.white;

  /// Dark green gradient behind the home header and page headers.
  static const headerGradient = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [Color(0xFF0E7A4B), Color(0xFF07502F), Color(0xFF053A22)],
  );

  // Neutrals
  static const background = Color(0xFFF1F1F1);
  static const surface = Colors.white;
  static const surfaceMuted = Color(0xFFF7F7F7);
  static const border = Color(0xFFE2E2E2);
  static const divider = Color(0xFFEAEAEA);
  static const textPrimary = Color(0xFF1C1C1E);
  static const textSecondary = Color(0xFF5F6368);
  static const textTertiary = Color(0xFF9AA0A6);
  static const textOnDark = Colors.white;
  static const textOnDarkMuted = Color(0xFFCFE6DA);

  // Semantic
  static const success = Color(0xFF12A35C);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFE5484D);
  static const info = Color(0xFF1F7AF0);
  static const notificationDot = Color(0xFFF04438);

  // Coin
  static const coin = Color(0xFFF5B400);
  static const coinLight = Color(0xFFFFE58A);

  // Daily reward cards (background / action)
  static const checkInSurface = Color(0xFFCDEBDD);
  static const checkInAction = Color(0xFF12A35C);
  static const spinSurface = Color(0xFFD9D3F3);
  static const spinAction = Color(0xFF6A4BE0);
  static const scratchSurface = Color(0xFFF6DEC4);
  static const scratchAction = Color(0xFFF7931A);
  static const captchaSurface = Color(0xFFCFDDF4);
  static const captchaAction = Color(0xFF1F7AF0);

  // Earn more cards
  static const readEarnSurface = Color(0xFF8EE6C4);
  static const shopEarnSurface = Color(0xFFF6A8F0);
  static const articleSurface = Color(0xFFA9C9FA);

  // Quiz accents
  static const quizPurple = Color(0xFF6A4BE0);
  static const quizBlue = Color(0xFF1F7AF0);
  static const quizOrange = Color(0xFFF7931A);

  // Quick action circles (fill / ring)
  static const rateFill = Color(0xFFFFE9A8);
  static const rateRing = Color(0xFFF5B400);
  static const leaderboardFill = Color(0xFFD7EBFF);
  static const leaderboardRing = Color(0xFF4A9DF5);
  static const contactFill = Color(0xFFD3F3E6);
  static const contactRing = Color(0xFF22B07D);
  static const inviteFill = Color(0xFFFFDCD3);
  static const inviteRing = Color(0xFFF2714B);

  // Leaderboard podium
  static const gold = Color(0xFFF5B400);
  static const silver = Color(0xFFA8B2BD);
  static const bronze = Color(0xFFCD7F4B);
}
