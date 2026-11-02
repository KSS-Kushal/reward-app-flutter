import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kavodnik/app/theme/app_theme.dart';
import 'package:kavodnik/core/ads/widgets/native_ad_slot.dart';
import 'package:kavodnik/features/rewards/data/datasources/rewards_mock_data_source.dart';
import 'package:kavodnik/features/rewards/di/rewards_dependencies.dart';
import 'package:kavodnik/features/rewards/presentation/screens/captcha_screen.dart';
import 'package:kavodnik/features/wallet/data/datasources/mock_wallet_ledger.dart';

import '../helpers/test_helpers.dart';

void main() {
  setUpAll(disableMockLatency);

  testWidgets('form → countdown → next captcha, with a native ad slot below', (
    tester,
  ) async {
    // A typical phone: 360 x 800 dp.
    tester.view
      ..physicalSize = const Size(1080, 2400)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final source = RewardsMockDataSource(MockWalletLedger());
    await tester.pumpWidget(
      ProviderScope(
        retry: (_, _) => null,
        overrides: [
          ...testOverrides(),
          rewardsRemoteDataSourceProvider.overrideWithValue(source),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const CaptchaScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Submit'), findsOneWidget);
    expect(find.byType(AdaptiveNativeAdSliver), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'WRONG1');
    await tester.tap(find.text('Submit'));
    await tester.pump();
    await tester.pump();

    expect(find.text('Not quite'), findsOneWidget);
    expect(find.textContaining('Next captcha in 10 seconds'), findsOneWidget);
    expect(find.byType(AdaptiveNativeAdSliver), findsOneWidget);

    await tester.pump(const Duration(seconds: 10));
    await tester.pump();
    await tester.pump();
    expect(find.text('Submit'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
