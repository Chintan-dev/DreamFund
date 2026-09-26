import '../domain/goal_model.dart';
import '../domain/contribution_model.dart';

abstract class GoalRepository {
  Future<List<GoalModel>> getGoals();
  Future<GoalModel?> getGoalById(String id);
  Future<void> addGoal(GoalModel goal);
  Future<void> updateGoal(GoalModel goal);
  Future<void> deleteGoal(String id);
  Future<void> addContribution(String goalId, ContributionModel contribution);
}

class MockGoalRepository implements GoalRepository {
  final List<GoalModel> _goals = [
    GoalModel(
      id: 'goal_001',
      title: 'Gaming PC Build',
      description: 'High performance RTX 5080 setup for work & gaming',
      targetAmount: 150000,
      currentSaved: 30000,
      plannedMonthlyContribution: 15000,
      targetDate: DateTime(2027, 3, 31),
      createdAt: DateTime(2026, 1, 1),
      category: GoalCategory.technology,
      isSharedWithFamily: false,
      createdByUserId: 'user_001',
      iconName: 'computer',
      contributions: [
        ContributionModel(
          id: 'c_001',
          goalId: 'goal_001',
          userId: 'user_001',
          userName: 'Chintan Patel',
          amount: 20000,
          date: DateTime(2026, 1, 15),
          note: 'Initial deposit from bonus',
        ),
        ContributionModel(
          id: 'c_002',
          goalId: 'goal_001',
          userId: 'user_001',
          userName: 'Chintan Patel',
          amount: 10000,
          date: DateTime(2026, 2, 10),
          note: 'Monthly savings contribution',
        ),
      ],
    ),
    GoalModel(
      id: 'goal_002',
      title: 'Europe Family Vacation',
      description: '14-day trip across Switzerland & Italy with family',
      targetAmount: 400000,
      currentSaved: 120000,
      plannedMonthlyContribution: 25000,
      targetDate: DateTime(2027, 12, 15),
      createdAt: DateTime(2025, 11, 1),
      category: GoalCategory.travel,
      isSharedWithFamily: true,
      createdByUserId: 'user_001',
      iconName: 'flight_takeoff',
      contributions: [
        ContributionModel(
          id: 'c_003',
          goalId: 'goal_002',
          userId: 'user_001',
          userName: 'Chintan Patel',
          amount: 70000,
          date: DateTime(2025, 11, 5),
          note: 'Vacation fund start',
        ),
        ContributionModel(
          id: 'c_004',
          goalId: 'goal_002',
          userId: 'user_002',
          userName: 'Family Member',
          amount: 50000,
          date: DateTime(2026, 1, 20),
          note: 'Shared contribution from salary',
        ),
      ],
    ),
    GoalModel(
      id: 'goal_003',
      title: 'Emergency Reserve Fund',
      description: '6 months liquid cash buffer',
      targetAmount: 200000,
      currentSaved: 180000,
      plannedMonthlyContribution: 10000,
      targetDate: DateTime(2026, 12, 31),
      createdAt: DateTime(2025, 6, 1),
      category: GoalCategory.emergency,
      isSharedWithFamily: true,
      createdByUserId: 'user_001',
      iconName: 'shield',
      contributions: [
        ContributionModel(
          id: 'c_005',
          goalId: 'goal_003',
          userId: 'user_001',
          userName: 'Chintan Patel',
          amount: 180000,
          date: DateTime(2025, 6, 5),
          note: 'Fixed reserve transfer',
        ),
      ],
    ),
  ];

  @override
  Future<List<GoalModel>> getGoals() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_goals);
  }

  @override
  Future<GoalModel?> getGoalById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _goals.firstWhere((g) => g.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> addGoal(GoalModel goal) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _goals.insert(0, goal);
  }

  @override
  Future<void> updateGoal(GoalModel goal) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _goals.indexWhere((g) => g.id == goal.id);
    if (index != -1) {
      _goals[index] = goal;
    }
  }

  @override
  Future<void> deleteGoal(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _goals.removeWhere((g) => g.id == id);
  }

  @override
  Future<void> addContribution(String goalId, ContributionModel contribution) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _goals.indexWhere((g) => g.id == goalId);
    if (index != -1) {
      final goal = _goals[index];
      final updatedContributions = List<ContributionModel>.from(goal.contributions)..insert(0, contribution);
      final newSaved = goal.currentSaved + contribution.amount;
      _goals[index] = goal.copyWith(
        currentSaved: newSaved,
        contributions: updatedContributions,
      );
    }
  }
}
