import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../data/auth_repository.dart';
import '../domain/user_model.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return MockAuthRepository();
});

class AuthNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final Ref _ref;

  AuthNotifier(this._ref) : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    try {
      final user = await _ref.read(authRepositoryProvider).getCurrentUser();
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signInGoogle() async {
    state = const AsyncValue.loading();
    try {
      final user = await _ref.read(authRepositoryProvider).signInWithGoogle();
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signOut() async {
    await _ref.read(authRepositoryProvider).signOut();
    state = const AsyncValue.data(null);
  }

  void addXp(int points) {
    state.whenData((user) {
      if (user != null) {
        final newXp = user.xp + points;
        final newLevel = (newXp / 200).floor() + 1;
        state = AsyncValue.data(user.copyWith(xp: newXp, level: newLevel));
      }
    });
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<UserModel?>>((ref) {
  return AuthNotifier(ref);
});
