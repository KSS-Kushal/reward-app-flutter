import 'package:flutter/material.dart';

import '../../../app/config/app_config.dart';
import '../../../app/router/route_names.dart';
import '../../../app/theme/app_colors.dart';

/// What a quick action does when tapped.
sealed class QuickActionTarget {
  const QuickActionTarget();
}

class OpenRoute extends QuickActionTarget {
  const OpenRoute(this.route);
  final String route;
}

class OpenExternalUrl extends QuickActionTarget {
  const OpenExternalUrl(this.url);
  final String url;
}

@immutable
class QuickAction {
  const QuickAction({
    required this.label,
    required this.icon,
    required this.fillColor,
    required this.ringColor,
    required this.target,
  });

  final String label;
  final IconData icon;
  final Color fillColor;
  final Color ringColor;
  final QuickActionTarget target;
}

/// The four circular shortcuts under the banner. This is app navigation, not
/// backend data, so it is plain configuration.
const homeQuickActions = [
  QuickAction(
    label: 'Rate Us',
    icon: Icons.star_rounded,
    fillColor: AppColors.rateFill,
    ringColor: AppColors.rateRing,
    target: OpenExternalUrl(AppConfig.playStoreUrl),
  ),
  QuickAction(
    label: 'Leader Board',
    icon: Icons.emoji_events_rounded,
    fillColor: AppColors.leaderboardFill,
    ringColor: AppColors.leaderboardRing,
    target: OpenRoute(AppRoutes.leaderboard),
  ),
  QuickAction(
    label: 'Contact Us',
    icon: Icons.support_agent_rounded,
    fillColor: AppColors.contactFill,
    ringColor: AppColors.contactRing,
    target: OpenRoute(AppRoutes.contactUs),
  ),
  QuickAction(
    label: 'Invite',
    icon: Icons.mark_email_unread_rounded,
    fillColor: AppColors.inviteFill,
    ringColor: AppColors.inviteRing,
    target: OpenRoute(AppRoutes.invite),
  ),
];
