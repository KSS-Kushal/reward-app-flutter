import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kavodnik/app/theme/app_colors.dart';
import 'package:kavodnik/core/widgets/app_button.dart';
import 'package:kavodnik/features/home/presentation/widgets/quick_action_item.dart';
import 'package:kavodnik/features/quiz/presentation/widgets/quiz_option_card.dart';
import 'package:kavodnik/features/rewards/domain/entities/reward_task.dart';
import 'package:kavodnik/features/rewards/presentation/reward_visuals.dart';
import 'package:kavodnik/features/rewards/presentation/widgets/reward_card.dart';
import 'package:kavodnik/features/wallet/domain/entities/wallet.dart';
import 'package:kavodnik/features/wallet/presentation/widgets/wallet_balance_card.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('QuickActionItem', () {
    testWidgets('shows its label and reacts to taps', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        themed(
          QuickActionItem(
            label: 'Leader Board',
            icon: Icons.emoji_events_rounded,
            fillColor: AppColors.leaderboardFill,
            ringColor: AppColors.leaderboardRing,
            onTap: () => taps++,
          ),
        ),
      );

      expect(find.text('Leader Board'), findsOneWidget);
      expect(find.byIcon(Icons.emoji_events_rounded), findsOneWidget);
      await tester.tap(find.byType(QuickActionItem));
      expect(taps, 1);
      expect(find.bySemanticsLabel('Leader Board'), findsOneWidget);
    });
  });

  group('RewardCard', () {
    Widget card({
      RewardTaskStatus status = RewardTaskStatus.available,
      VoidCallback? onPressed,
      bool isLoading = false,
    }) {
      const type = RewardTaskType.spinWheel;
      return themed(
        SizedBox(
          width: 100,
          height: 150,
          child: RewardCard(
            title: 'Spin Wheel',
            actionLabel: 'Spin',
            visual: type.visual(),
            surfaceColor: type.surfaceColor,
            actionColor: type.actionColor,
            status: status,
            isLoading: isLoading,
            onPressed: onPressed,
          ),
        ),
      );
    }

    testWidgets('available card runs its action', (tester) async {
      var pressed = 0;
      await tester.pumpWidget(card(onPressed: () => pressed++));
      expect(find.text('Spin Wheel'), findsOneWidget);
      await tester.tap(find.text('Spin'));
      expect(pressed, 1);
    });

    testWidgets('completed card shows Done with a disabled pill', (
      tester,
    ) async {
      var pressed = 0;
      await tester.pumpWidget(
        card(status: RewardTaskStatus.completed, onPressed: () => pressed++),
      );
      expect(find.text('Done'), findsOneWidget);
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
      final pill = tester.widget<AppPillButton>(find.byType(AppPillButton));
      expect(pill.onPressed, isNull);
    });

    testWidgets('locked card cannot be opened', (tester) async {
      var pressed = 0;
      await tester.pumpWidget(
        card(status: RewardTaskStatus.locked, onPressed: () => pressed++),
      );
      expect(find.text('Locked'), findsOneWidget);
      await tester.tap(find.byType(RewardCard));
      expect(pressed, 0);
    });

    testWidgets('loading card shows a skeleton instead of the pill', (
      tester,
    ) async {
      await tester.pumpWidget(card(isLoading: true));
      expect(find.byType(AppPillButton), findsNothing);
    });
  });

  group('WalletBalanceCard', () {
    const wallet = Wallet(
      balance: 2450,
      totalEarned: 3450,
      pendingCoins: 340,
      totalRedeemed: 1000,
      coinsPerCurrencyUnit: 100,
      currencySymbol: '₹',
      minRedeemCoins: 1000,
    );

    testWidgets('formats balance and currency value', (tester) async {
      await tester.pumpWidget(
        themed(
          const ColoredBox(
            color: AppColors.primaryDark,
            child: WalletBalanceCard(wallet: wallet),
          ),
        ),
      );
      expect(find.text('2,450'), findsOneWidget);
      expect(find.text('≈ ₹24.50'), findsOneWidget);
      expect(find.text('Redeem'), findsNothing);
    });

    testWidgets('redeem is disabled below the minimum balance', (tester) async {
      const poor = Wallet(
        balance: 120,
        totalEarned: 120,
        pendingCoins: 0,
        totalRedeemed: 0,
        coinsPerCurrencyUnit: 100,
        currencySymbol: '₹',
        minRedeemCoins: 1000,
      );
      var redeemed = 0;
      await tester.pumpWidget(
        themed(WalletBalanceCard(wallet: poor, onRedeem: () => redeemed++)),
      );
      await tester.tap(find.text('Redeem'));
      expect(redeemed, 0);
    });
  });

  group('QuizOptionCard', () {
    testWidgets('renders label and text and handles taps', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        themed(
          QuizOptionCard(label: 'A', text: 'Canberra', onTap: () => taps++),
        ),
      );
      expect(find.text('A'), findsOneWidget);
      expect(find.text('Canberra'), findsOneWidget);
      await tester.tap(find.text('Canberra'));
      expect(taps, 1);
    });

    testWidgets('shows feedback icons for correct and incorrect', (
      tester,
    ) async {
      await tester.pumpWidget(
        themed(
          const Column(
            children: [
              QuizOptionCard(
                label: 'A',
                text: 'Right',
                state: QuizOptionState.correct,
              ),
              QuizOptionCard(
                label: 'B',
                text: 'Wrong',
                state: QuizOptionState.incorrect,
              ),
            ],
          ),
        ),
      );
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
      expect(find.byIcon(Icons.cancel_rounded), findsOneWidget);
    });
  });
}
