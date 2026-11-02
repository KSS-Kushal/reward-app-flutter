import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kavodnik/app/theme/app_theme.dart';
import 'package:kavodnik/features/rewards/data/datasources/rewards_mock_data_source.dart';
import 'package:kavodnik/features/rewards/data/models/reward_game_models.dart';
import 'package:kavodnik/features/rewards/di/rewards_dependencies.dart';
import 'package:kavodnik/features/rewards/presentation/screens/scratch_card_screen.dart';
import 'package:kavodnik/features/rewards/presentation/widgets/scratch_overlay.dart';
import 'package:kavodnik/features/wallet/data/datasources/mock_wallet_ledger.dart';

import '../helpers/test_helpers.dart';

void main() {
  setUpAll(disableMockLatency);

  testWidgets('a small scratch shows the prize from the reveal response, '
      'without a loader or another GET', (tester) async {
    final source = _CountingSource(MockWalletLedger());
    await tester.pumpWidget(
      ProviderScope(
        retry: (_, _) => null,
        overrides: [
          ...testOverrides(),
          rewardsRemoteDataSourceProvider.overrideWithValue(source),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const ScratchCardScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
    expect(source.statusCalls, 1);
    expect(find.text('Keep scratching!'), findsOneWidget);

    // A short stroke: far below the reveal threshold.
    final card = find.byType(ScratchOverlay);
    final gesture = await tester.startGesture(tester.getCenter(card));
    for (var i = 0; i < 4; i++) {
      await gesture.moveBy(const Offset(12, 0));
      await tester.pump();
    }
    await gesture.up();
    await tester.pump();
    await tester.pump();

    expect(source.revealCalls, 1);
    final coins = source.lastReveal!.coinsWon;
    expect(find.text('+$coins coins'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(source.statusCalls, 1, reason: 'no extra GET /scratch-card');

    await tester.pumpWidget(const SizedBox.shrink());
  });
}

class _CountingSource extends RewardsMockDataSource {
  _CountingSource(super.ledger);

  int statusCalls = 0;
  int revealCalls = 0;
  ScratchResultModel? lastReveal;

  @override
  Future<ScratchCardStatusModel> getScratchCard() {
    statusCalls += 1;
    return super.getScratchCard();
  }

  @override
  Future<ScratchResultModel> revealScratchCard(String cardId) async {
    revealCalls += 1;
    return lastReveal = await super.revealScratchCard(cardId);
  }
}
