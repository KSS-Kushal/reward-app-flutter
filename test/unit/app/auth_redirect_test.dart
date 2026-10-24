import 'package:flutter_test/flutter_test.dart';
import 'package:kavodnik/app/router/auth_redirect.dart';
import 'package:kavodnik/app/router/route_names.dart';
import 'package:kavodnik/features/authentication/domain/entities/user.dart';
import 'package:kavodnik/features/authentication/presentation/providers/auth_state.dart';

void main() {
  final signedIn = AuthAuthenticated(
    User(id: '1', name: 'A', email: 'a@b.c', joinedAt: DateTime(2026)),
  );

  test('stays on splash while the session is being restored', () {
    expect(authRedirect(const AuthInitial(), AppRoutes.splash), isNull);
    expect(
      authRedirect(const AuthInitial(), AppRoutes.wallet),
      AppRoutes.splash,
    );
  });

  test('guests are sent to login from protected routes', () {
    for (final route in [
      AppRoutes.home,
      AppRoutes.rewards,
      AppRoutes.wallet,
      AppRoutes.profile,
      AppRoutes.spinWheel,
    ]) {
      expect(authRedirect(const AuthUnauthenticated(), route), AppRoutes.login);
    }
    expect(authRedirect(const AuthUnauthenticated(), AppRoutes.login), isNull);
    expect(authRedirect(const AuthError('x'), AppRoutes.login), isNull);
  });

  test('signed-in users skip splash and login', () {
    expect(authRedirect(signedIn, AppRoutes.login), AppRoutes.home);
    expect(authRedirect(signedIn, AppRoutes.splash), AppRoutes.home);
    expect(authRedirect(signedIn, AppRoutes.wallet), isNull);
  });
}
