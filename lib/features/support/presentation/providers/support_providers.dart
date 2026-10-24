import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../di/support_dependencies.dart';
import '../../domain/entities/support_info.dart';

final supportInfoProvider = FutureProvider.autoDispose<SupportInfo>(
  (ref) => ref.watch(getSupportInfoProvider).call(),
);
