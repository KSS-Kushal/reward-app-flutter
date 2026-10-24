import '../../features/authentication/presentation/providers/auth_state.dart';
import 'route_names.dart';

/// Route guard. Pure function so it can be unit tested.
///
/// * While the stored session is being checked, stay on the splash screen.
/// * Signed-in users never see splash/login.
/// * Everyone else is sent to login.
String? authRedirect(AuthState auth, String location) {
  final atSplash = location == AppRoutes.splash;
  final atLogin = location == AppRoutes.login;

  return switch (auth) {
    AuthInitial() => atSplash ? null : AppRoutes.splash,
    AuthAuthenticated() => atSplash || atLogin ? AppRoutes.home : null,
    AuthLoading() ||
    AuthUnauthenticated() ||
    AuthError() => atLogin ? null : AppRoutes.login,
  };
}
