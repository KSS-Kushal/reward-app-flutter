import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/coin_icon.dart';
import '../../domain/entities/leaderboard.dart';

/// Top-three podium.
class LeaderboardPodium extends StatelessWidget {
  const LeaderboardPodium({required this.entries, super.key});

  final List<LeaderboardEntry> entries;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const SizedBox.shrink();
    // Visual order: 2nd, 1st, 3rd.
    final order = [
      if (entries.length > 1) entries[1],
      entries[0],
      if (entries.length > 2) entries[2],
    ];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (final entry in order) Expanded(child: _PodiumSpot(entry: entry)),
      ],
    );
  }
}

class _PodiumSpot extends StatelessWidget {
  const _PodiumSpot({required this.entry});

  final LeaderboardEntry entry;

  @override
  Widget build(BuildContext context) {
    final first = entry.rank == 1;
    final medal = switch (entry.rank) {
      1 => AppColors.gold,
      2 => AppColors.silver,
      _ => AppColors.bronze,
    };
    return Semantics(
      label: 'Rank ${entry.rank}, ${entry.name}, ${entry.points} points',
      excludeSemantics: true,
      child: Column(
        children: [
          if (first)
            const Icon(Icons.emoji_events_rounded, color: AppColors.gold),
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              AppAvatar(
                name: entry.name,
                imageUrl: entry.avatarUrl,
                size: first ? 76 : 60,
                borderColor: medal,
                borderWidth: 3,
              ),
              Positioned(
                bottom: -10,
                child: CircleAvatar(
                  radius: 12,
                  backgroundColor: medal,
                  child: Text(
                    '${entry.rank}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            entry.name.split(' ').first,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textOnDark,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            Formatters.compact(entry.points),
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textOnDarkMuted,
            ),
          ),
        ],
      ),
    );
  }
}

/// One ranked row (rank 4 onwards, and the current user's card).
class LeaderboardTile extends StatelessWidget {
  const LeaderboardTile({required this.entry, super.key});

  final LeaderboardEntry entry;

  @override
  Widget build(BuildContext context) {
    final highlight = entry.isCurrentUser;
    return AppCard(
      color: highlight ? AppColors.primaryLight : AppColors.surface,
      border: highlight ? Border.all(color: AppColors.primary) : null,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Text(
              '#${entry.rank}',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          AppAvatar(name: entry.name, imageUrl: entry.avatarUrl, size: 40),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              highlight ? '${entry.name} (You)' : entry.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: highlight ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
          CoinAmount(amount: entry.points),
        ],
      ),
    );
  }
}
