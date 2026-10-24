import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kavodnik/app/app.dart';
import 'package:kavodnik/features/authentication/data/datasources/auth_mock_data_source.dart';
import 'package:kavodnik/features/authentication/data/datasources/mock_user_store.dart';
import 'package:kavodnik/features/authentication/data/models/auth_session_model.dart';
import 'package:kavodnik/features/authentication/data/models/user_model.dart';
import 'package:kavodnik/features/authentication/di/auth_dependencies.dart';
import 'package:kavodnik/features/authentication/presentation/screens/login_screen.dart';
import 'package:kavodnik/features/home/presentation/screens/home_screen.dart';
import 'package:kavodnik/features/wallet/presentation/screens/wallet_screen.dart';

import '../helpers/test_helpers.dart';

/// Demo user without a network avatar, so no image requests are made.
final _testUser = UserModel(
  id: 'user_001',
  name: 'Ritik Sharma',
  email: 'ritik@example.com',
  joinedAt: DateTime(2026, 3, 14),
  referralCode: 'RITIK250',
);

Future<void> _pumpFor(WidgetTester tester, [int frames = 10]) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  setUpAll(disableMockLatency);

  testWidgets('demo sign-in reaches home, tabs work, logout returns to login', (
    tester,
  ) async {
    // Tall viewport so every home section is laid out.
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.6;
    addTearDown(tester.view.reset);

    final store = MockUserStore();
    await tester.pumpWidget(
      ProviderScope(
        retry: (_, _) => null,
        overrides: [
          ...testOverrides(),
          authRemoteDataSourceProvider.overrideWithValue(
            _UserAwareMock(store, _testUser),
          ),
        ],
        child: const KavodnikApp(),
      ),
    );
    await _pumpFor(tester);

    // Splash -> login (no stored session).
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);

    await tester.tap(find.text('Continue as demo user'));
    await _pumpFor(tester, 20);

    // Home, built from the Figma sections.
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Hi, Ritik', findRichText: true), findsOneWidget);
    expect(find.text('Welcome to Kavodnik'), findsOneWidget);
    for (final label in ['Rate Us', 'Leader Board', 'Contact Us', 'Invite']) {
      expect(find.text(label), findsOneWidget);
    }
    expect(find.text('Daily Rewards'), findsOneWidget);
    expect(find.text('Daily Check-in'), findsOneWidget);
    expect(find.text('Earn More'), findsOneWidget);
    expect(find.text('Quiz Zone'), findsOneWidget);

    // Bottom navigation.
    await tester.tap(find.text('Wallet'));
    await _pumpFor(tester);
    expect(find.byType(WalletScreen), findsOneWidget);
    expect(find.text('Available balance'), findsOneWidget);

    // Profile -> logout.
    await tester.tap(find.text('Profile'));
    await _pumpFor(tester);
    expect(find.text('ritik@example.com'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Log out'), 200);
    await tester.tap(find.text('Log out'));
    await _pumpFor(tester, 3);
    await tester.tap(find.widgetWithText(TextButton, 'Log out'));
    await _pumpFor(tester);
    expect(find.byType(LoginScreen), findsOneWidget);

    // Dispose the tree so periodic timers (banner auto-scroll) stop.
    await tester.pumpWidget(const SizedBox.shrink());
  });
}

/// Mock auth backend that signs in as [user].
class _UserAwareMock extends AuthMockDataSource {
  _UserAwareMock(super.store, this.user);

  final UserModel user;

  @override
  Future<AuthSessionModel> loginWithGoogle({required String idToken}) => super
      .loginWithGoogle(idToken: idToken)
      .then(
        (session) => AuthSessionModel(
          accessToken: session.accessToken,
          refreshToken: session.refreshToken,
          user: user,
        ),
      );

  @override
  Future<UserModel> getCurrentUser() async => user;
}
