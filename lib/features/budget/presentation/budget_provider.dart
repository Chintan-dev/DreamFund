import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:uuid/uuid.dart';
import '../data/budget_repository.dart';
import '../domain/budget_model.dart';
import '../domain/transaction_model.dart';

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  return MockBudgetRepository();
});

class BudgetNotifier extends StateNotifier<AsyncValue<BudgetSummary>> {
  final Ref _ref;
  final _uuid = const Uuid();

  BudgetNotifier(this._ref) : super(const AsyncValue.loading()) {
    loadBudget();
  }

  Future<void> loadBudget() async {
    state = const AsyncValue.loading();
    try {
      final repo = _ref.read(budgetRepositoryProvider);
      final summary = await repo.getBudgetSummary();
      state = AsyncValue.data(summary);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addTransaction({
    required String title,
    required double amount,
    required TransactionType type,
    required String category,
    String? note,
  }) async {
    final tx = TransactionModel(
      id: _uuid.v4(),
      title: title,
      amount: amount,
      type: type,
      category: category,
      date: DateTime.now(),
      note: note,
    );

    try {
      final repo = _ref.read(budgetRepositoryProvider);
      await repo.addTransaction(tx);
      await loadBudget();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final budgetProvider = StateNotifierProvider<BudgetNotifier, AsyncValue<BudgetSummary>>((ref) {
  return BudgetNotifier(ref);
});
