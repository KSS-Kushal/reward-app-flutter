import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../notifications/presentation/providers/notification_providers.dart';
import '../../../quiz/presentation/providers/quiz_providers.dart';
import '../../../rewards/presentation/providers/rewards_providers.dart';
import '../../../wallet/presentation/providers/wallet_providers.dart';
import '../../di/home_dependencies.dart';
import '../../domain/entities/earn_option.dart';
import '../../domain/entities/promo_banner.dart';

final homeBannersProvider = FutureProvider.autoDispose<List<PromoBanner>>(
  (ref) => ref.watch(getHomeBannersProvider).call(),
);

final earnOptionsProvider = FutureProvider.autoDispose<List<EarnOption>>(
  (ref) => ref.watch(getEarnOptionsProvider).call(),
);

/// Pull-to-refresh on the home screen. Each section reloads independently,
/// so one slow or failing section never blocks the others.
Future<void> refreshHome(WidgetRef ref) async {
  ref
    ..invalidate(homeBannersProvider)
    ..invalidate(earnOptionsProvider)
    ..invalidate(walletProvider)
    ..invalidate(dailyRewardsProvider)
    ..invalidate(quizCategoriesProvider)
    ..invalidate(unreadNotificationCountProvider);
  try {
    await ref.read(dailyRewardsProvider.future);
  } on Object {
    // Each section renders its own error state; nothing to do here.
  }
}
