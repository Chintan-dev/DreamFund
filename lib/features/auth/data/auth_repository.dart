import '../domain/user_model.dart';

abstract class AuthRepository {
  Future<UserModel?> getCurrentUser();
  Future<UserModel> signInWithGoogle();
  Future<UserModel> signInWithPhone(String phoneNumber, String otp);
  Future<void> signOut();
}

class MockAuthRepository implements AuthRepository {
  UserModel? _currentUser = UserModel(
    id: 'user_001',
    name: 'Chintan Patel',
    email: 'chintan@dreamfund.app',
    avatarUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Chintan',
    familyId: 'family_101',
    xp: 450,
    level: 3,
    currentStreakDays: 5,
  );

  @override
  Future<UserModel?> getCurrentUser() async {
    return _currentUser;
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    await Future.delayed(const Duration(milliseconds: 600));
    _currentUser = UserModel(
      id: 'user_001',
      name: 'Chintan Patel',
      email: 'chintan@dreamfund.app',
      avatarUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Chintan',
      familyId: 'family_101',
      xp: 450,
      level: 3,
      currentStreakDays: 5,
    );
    return _currentUser!;
  }

  @override
  Future<UserModel> signInWithPhone(String phoneNumber, String otp) async {
    await Future.delayed(const Duration(milliseconds: 600));
    _currentUser = UserModel(
      id: 'user_002',
      name: 'Family Member',
      email: 'member@dreamfund.app',
      avatarUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Family',
      familyId: 'family_101',
      xp: 150,
      level: 1,
      currentStreakDays: 2,
    );
    return _currentUser!;
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
  }
}
