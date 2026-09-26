import 'transaction_model.dart';

class CategoryBudget {
  final String categoryName;
  final double allocated;
  final double spent;

  CategoryBudget({
    required this.categoryName,
    required this.allocated,
    required this.spent,
  });

  double get remaining => (allocated - spent).clamp(0.0, double.infinity);
  double get percentage => allocated > 0 ? (spent / allocated).clamp(0.0, 1.0) : 0.0;
}

class BudgetSummary {
  final double monthlyIncome;
  final double monthlyExpenses;
  final double totalAllocatedToGoals;
  final List<CategoryBudget> categoryBudgets;
  final List<TransactionModel> recentTransactions;

  BudgetSummary({
    required this.monthlyIncome,
    required this.monthlyExpenses,
    required this.totalAllocatedToGoals,
    required this.categoryBudgets,
    required this.recentTransactions,
  });

  double get unallocatedSurplus => monthlyIncome - monthlyExpenses - totalAllocatedToGoals;
}
