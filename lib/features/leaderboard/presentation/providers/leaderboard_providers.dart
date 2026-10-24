import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../di/leaderboard_dependencies.dart';
import '../../domain/entities/leaderboard.dart';

final leaderboardProvider = FutureProvider.autoDispose
    .family<Leaderboard, LeaderboardPeriod>(
      (ref, period) => ref.watch(getLeaderboardProvider).call(period),
    );
