import '../domain/budget_model.dart';
import '../domain/transaction_model.dart';

abstract class BudgetRepository {
  Future<BudgetSummary> getBudgetSummary();
  Future<void> addTransaction(TransactionModel transaction);
}

class MockBudgetRepository implements BudgetRepository {
  double _monthlyIncome = 125000;
  double _totalAllocatedToGoals = 50000;

  final List<TransactionModel> _transactions = [
    TransactionModel(
      id: 't_001',
      title: 'Software Engineer Salary',
      amount: 125000,
      type: TransactionType.income,
      category: 'Salary',
      date: DateTime(2026, 9, 1),
    ),
    TransactionModel(
      id: 't_002',
      title: 'Apartment Rent & Maintenance',
      amount: 28000,
      type: TransactionType.expense,
      category: 'Housing',
      date: DateTime(2026, 9, 2),
    ),
    TransactionModel(
      id: 't_003',
      title: 'Groceries & Supermarket',
      amount: 12500,
      type: TransactionType.expense,
      category: 'Food',
      date: DateTime(2026, 9, 10),
    ),
    TransactionModel(
      id: 't_004',
      title: 'High Speed Internet & Utilities',
      amount: 3500,
      type: TransactionType.expense,
      category: 'Utilities',
      date: DateTime(2026, 9, 12),
    ),
    TransactionModel(
      id: 't_005',
      title: 'Goal Contribution - Gaming PC',
      amount: 15000,
      type: TransactionType.expense,
      category: 'Dream Fund',
      date: DateTime(2026, 9, 15),
    ),
  ];

  @override
  Future<BudgetSummary> getBudgetSummary() async {
    await Future.delayed(const Duration(milliseconds: 300));

    double totalExpenses = 0;
    for (var tx in _transactions) {
      if (tx.type == TransactionType.expense) {
        totalExpenses += tx.amount;
      }
    }

    final categoryBudgets = [
      CategoryBudget(categoryName: 'Housing', allocated: 30000, spent: 28000),
      CategoryBudget(categoryName: 'Food & Dining', allocated: 18000, spent: 12500),
      CategoryBudget(categoryName: 'Utilities & Bills', allocated: 5000, spent: 3500),
      CategoryBudget(categoryName: 'Entertainment', allocated: 10000, spent: 4500),
      CategoryBudget(categoryName: 'DreamFund Goals', allocated: 50000, spent: 50000),
    ];

    return BudgetSummary(
      monthlyIncome: _monthlyIncome,
      monthlyExpenses: totalExpenses,
      totalAllocatedToGoals: _totalAllocatedToGoals,
      categoryBudgets: categoryBudgets,
      recentTransactions: _transactions,
    );
  }

  @override
  Future<void> addTransaction(TransactionModel transaction) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _transactions.insert(0, transaction);
  }
}
