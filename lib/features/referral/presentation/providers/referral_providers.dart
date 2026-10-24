import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../di/referral_dependencies.dart';
import '../../domain/entities/referral.dart';

final referralInfoProvider = FutureProvider.autoDispose<ReferralInfo>(
  (ref) => ref.watch(getReferralInfoProvider).call(),
);
