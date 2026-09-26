import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:uuid/uuid.dart';
import '../data/goal_repository.dart';
import '../domain/goal_model.dart';
import '../domain/contribution_model.dart';
import '../../auth/presentation/auth_provider.dart';

final goalRepositoryProvider = Provider<GoalRepository>((ref) {
  return MockGoalRepository();
});

class GoalNotifier extends StateNotifier<AsyncValue<List<GoalModel>>> {
  final Ref _ref;
  final _uuid = const Uuid();

  GoalNotifier(this._ref) : super(const AsyncValue.loading()) {
    loadGoals();
  }

  Future<void> loadGoals() async {
    state = const AsyncValue.loading();
    try {
      final repo = _ref.read(goalRepositoryProvider);
      final goals = await repo.getGoals();
      state = AsyncValue.data(goals);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createGoal({
    required String title,
    required String description,
    required double targetAmount,
    required double initialSaved,
    required double plannedMonthlyContribution,
    required DateTime targetDate,
    required GoalCategory category,
    required bool isSharedWithFamily,
  }) async {
    final user = _ref.read(authProvider).value;
    final userId = user?.id ?? 'user_001';
    final userName = user?.name ?? 'Chintan Patel';

    final initialContributions = <ContributionModel>[];
    if (initialSaved > 0) {
      initialContributions.add(
        ContributionModel(
          id: _uuid.v4(),
          goalId: '',
          userId: userId,
          userName: userName,
          amount: initialSaved,
          date: DateTime.now(),
          note: 'Initial deposit',
        ),
      );
    }

    final newGoal = GoalModel(
      id: _uuid.v4(),
      title: title,
      description: description,
      targetAmount: targetAmount,
      currentSaved: initialSaved,
      plannedMonthlyContribution: plannedMonthlyContribution,
      targetDate: targetDate,
      createdAt: DateTime.now(),
      category: category,
      isSharedWithFamily: isSharedWithFamily,
      createdByUserId: userId,
      contributions: initialContributions,
    );

    try {
      final repo = _ref.read(goalRepositoryProvider);
      await repo.addGoal(newGoal);
      await loadGoals();
      _ref.read(authProvider.notifier).addXp(50);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addContribution({
    required String goalId,
    required double amount,
    String? note,
  }) async {
    final user = _ref.read(authProvider).value;
    final userId = user?.id ?? 'user_001';
    final userName = user?.name ?? 'Chintan Patel';

    final contribution = ContributionModel(
      id: _uuid.v4(),
      goalId: goalId,
      userId: userId,
      userName: userName,
      amount: amount,
      date: DateTime.now(),
      note: note,
    );

    try {
      final repo = _ref.read(goalRepositoryProvider);
      await repo.addContribution(goalId, contribution);
      await loadGoals();
      _ref.read(authProvider.notifier).addXp(25);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteGoal(String id) async {
    try {
      final repo = _ref.read(goalRepositoryProvider);
      await repo.deleteGoal(id);
      await loadGoals();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final goalProvider = StateNotifierProvider<GoalNotifier, AsyncValue<List<GoalModel>>>((ref) {
  return GoalNotifier(ref);
});
