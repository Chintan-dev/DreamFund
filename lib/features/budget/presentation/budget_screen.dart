import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import 'budget_provider.dart';
import '../domain/transaction_model.dart';

class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetAsync = ref.watch(budgetProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Budget & Cashflow'),
      ),
      body: budgetAsync.when(
        data: (budget) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Income / Expense / Surplus Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        'Monthly Income',
                        CurrencyFormatter.formatINR(budget.monthlyIncome),
                        Icons.arrow_downward,
                        AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildSummaryCard(
                        'Expenses & Bills',
                        CurrencyFormatter.formatINR(budget.monthlyExpenses),
                        Icons.arrow_upward,
                        AppColors.error,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildSummaryCard(
                        'Allocated to Goals',
                        CurrencyFormatter.formatINR(budget.totalAllocatedToGoals),
                        Icons.savings,
                        AppColors.primary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Surplus Banner
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: budget.unallocatedSurplus >= 0
                        ? AppColors.primary.withAlpha(20)
                        : AppColors.error.withAlpha(20),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: budget.unallocatedSurplus >= 0
                          ? AppColors.primary.withAlpha(60)
                          : AppColors.error.withAlpha(60),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        budget.unallocatedSurplus >= 0 ? Icons.check_circle : Icons.warning_amber,
                        color: budget.unallocatedSurplus >= 0 ? AppColors.primary : AppColors.error,
                        size: 28,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Unallocated Monthly Surplus: ${CurrencyFormatter.formatINR(budget.unallocatedSurplus)}',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              budget.unallocatedSurplus >= 0
                                  ? 'Great job! You have extra room in your budget to accelerate your savings dreams.'
                                  : 'Your monthly expenses and goal targets exceed income. Consider adjusting goal timelines.',
                              style: const TextStyle(fontSize: 13, color: AppColors.lightTextSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // Category Budgets Breakdown
                const Text('Category Budgets', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),

                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: budget.categoryBudgets.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final cat = budget.categoryBudgets[index];
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(cat.categoryName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                Text(
                                  '${CurrencyFormatter.formatINR(cat.spent)} / ${CurrencyFormatter.formatINR(cat.allocated)}',
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            LinearPercentIndicator(
                              lineHeight: 8.0,
                              percent: cat.percentage,
                              backgroundColor: AppColors.lightCardBorder,
                              progressColor: cat.percentage >= 1.0 ? AppColors.error : AppColors.secondary,
                              barRadius: const Radius.circular(4),
                              padding: EdgeInsets.zero,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 28),

                // Recent Transactions Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Recent Income & Expense Log', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ElevatedButton.icon(
                      onPressed: () => _showAddTransactionDialog(context, ref),
                      icon: const Icon(Icons.add),
                      label: const Text('+ Transaction'),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: budget.recentTransactions.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final tx = budget.recentTransactions[index];
                    final isIncome = tx.type == TransactionType.income;
                    return Card(
                      margin: EdgeInsets.zero,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isIncome ? AppColors.success.withAlpha(30) : AppColors.error.withAlpha(30),
                          child: Icon(
                            isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                            color: isIncome ? AppColors.success : AppColors.error,
                            size: 20,
                          ),
                        ),
                        title: Text(tx.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${tx.category} • ${CurrencyFormatter.formatFullDate(tx.date)}'),
                        trailing: Text(
                          '${isIncome ? "+" : "-"}${CurrencyFormatter.formatINR(tx.amount)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: isIncome ? AppColors.success : AppColors.error,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Text('Error loading budget: $err'),
      ),
    );
  }

  Widget _buildSummaryCard(String label, String amount, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 18),
                const SizedBox(width: 8),
                Text(label, style: const TextStyle(fontSize: 12, color: AppColors.lightTextSecondary)),
              ],
            ),
            const SizedBox(height: 8),
            Text(amount, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  void _showAddTransactionDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    final categoryController = TextEditingController();
    TransactionType type = TransactionType.expense;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Transaction'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Expense'),
                      selected: type == TransactionType.expense,
                      selectedColor: AppColors.error,
                      labelStyle: TextStyle(color: type == TransactionType.expense ? Colors.white : Colors.black),
                      onSelected: (val) => setState(() => type = TransactionType.expense),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Income'),
                      selected: type == TransactionType.income,
                      selectedColor: AppColors.success,
                      labelStyle: TextStyle(color: type == TransactionType.income ? Colors.white : Colors.black),
                      onSelected: (val) => setState(() => type = TransactionType.income),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title (e.g. Salary, Groceries)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Amount (₹)', prefixText: '₹ ', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(labelText: 'Category (e.g. Food, Housing)', border: OutlineInputBorder()),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final amt = double.tryParse(amountController.text) ?? 0;
                if (amt > 0 && titleController.text.isNotEmpty) {
                  ref.read(budgetProvider.notifier).addTransaction(
                        title: titleController.text.trim(),
                        amount: amt,
                        type: type,
                        category: categoryController.text.trim().isNotEmpty ? categoryController.text.trim() : 'General',
                      );
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Transaction recorded!')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Save Transaction'),
            ),
          ],
        ),
      ),
    );
  }
}
