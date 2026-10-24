import 'package:flutter/widgets.dart';

/// Spacing scale (4pt grid).
abstract final class AppSpacing {
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;

  /// Horizontal padding of every page.
  static const double page = 16;

  /// Vertical gap between home sections.
  static const double section = 28;
}

/// Corner radius scale.
abstract final class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double sheet = 28;
  static const double pill = 999;

  static const BorderRadius smAll = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdAll = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgAll = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius xlAll = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius pillAll = BorderRadius.all(Radius.circular(pill));
  static const BorderRadius sheetTop = BorderRadius.vertical(
    top: Radius.circular(sheet),
  );
}

/// Component sizes.
abstract final class AppSizes {
  static const double avatarSm = 36;
  static const double avatarMd = 48;
  static const double avatarLg = 88;
  static const double headerIconButton = 42;
  static const double quickActionCircle = 54;
  static const double iconSm = 16;
  static const double iconMd = 22;
  static const double iconLg = 28;
  static const double buttonHeight = 52;
  static const double pillButtonHeight = 28;
  static const double bottomNavHeight = 68;

  /// Space to leave below scrollable content so the floating bottom
  /// navigation never hides the last item.
  static const double bottomNavClearance = bottomNavHeight + 32;
}

/// Animation durations.
abstract final class AppDurations {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 600);
  static const Duration bannerAutoScroll = Duration(seconds: 5);
}
