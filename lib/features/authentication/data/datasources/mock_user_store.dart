import '../models/user_model.dart';

/// In-memory stand-in for the backend's user table, shared by every mock
/// data source that reads or edits the current user.
class MockUserStore {
  UserModel? currentUser;

  static final UserModel demoUser = UserModel(
    id: 'user_001',
    name: 'Ritik Sharma',
    email: 'ritik.sharma@example.com',
    avatarUrl: 'https://i.pravatar.cc/300?img=12',
    phone: '+91 98765 43210',
    referralCode: 'RITIK250',
    joinedAt: DateTime(2026, 3, 14),
  );
}
