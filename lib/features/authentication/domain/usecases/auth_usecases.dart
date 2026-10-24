import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class SignInWithGoogle {
  const SignInWithGoogle(this._repository);
  final AuthRepository _repository;

  Future<User> call() => _repository.signInWithGoogle();
}

class SignInAsDemoUser {
  const SignInAsDemoUser(this._repository);
  final AuthRepository _repository;

  Future<User> call() => _repository.signInAsDemoUser();
}

class RestoreSession {
  const RestoreSession(this._repository);
  final AuthRepository _repository;

  Future<User?> call() => _repository.restoreSession();
}

class SignOut {
  const SignOut(this._repository);
  final AuthRepository _repository;

  Future<void> call() => _repository.signOut();
}
