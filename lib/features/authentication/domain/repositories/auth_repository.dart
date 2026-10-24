import '../entities/user.dart';

abstract interface class AuthRepository {
  /// Runs Google Sign-In, exchanges the ID token with the backend and
  /// persists the resulting session.
  Future<User> signInWithGoogle();

  /// Development-only sign-in against mock data (no Google account needed).
  Future<User> signInAsDemoUser();

  /// Returns the stored user if a valid session exists, otherwise `null`.
  Future<User?> restoreSession();

  /// Ends the session locally and remotely (best effort).
  Future<void> signOut();

  /// Clears local session data without contacting the backend
  /// (used when the backend already rejected the token).
  Future<void> clearLocalSession();

  /// Persists an updated copy of the current user.
  Future<void> cacheUser(User user);
}
