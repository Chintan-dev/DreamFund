import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/calculation_engine.dart';
import 'goal_provider.dart';
import '../domain/goal_model.dart';

class GoalDetailScreen extends ConsumerWidget {
  final String goalId;

  const GoalDetailScreen({super.key, required this.goalId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(goalProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dream Goal Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/goals'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      body: goalsAsync.when(
        data: (goals) {
          final goal = goals.firstWhere(
            (g) => g.id == goalId,
            orElse: () => GoalModel(
              id: '',
              title: 'Not Found',
              description: '',
              targetAmount: 0,
              currentSaved: 0,
              plannedMonthlyContribution: 0,
              targetDate: DateTime.now(),
              createdAt: DateTime.now(),
              category: GoalCategory.other,
              isSharedWithFamily: false,
              createdByUserId: '',
            ),
          );

          if (goal.id.isEmpty) {
            return const Center(child: Text('Goal not found'));
          }

          final calcResult = CalculationEngine.calculateGoalPlan(
            targetAmount: goal.targetAmount,
            currentSaved: goal.currentSaved,
            targetDate: goal.targetDate,
            plannedMonthlyContribution: goal.plannedMonthlyContribution,
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(goal.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                            Text(
                              CurrencyFormatter.formatINR(goal.targetAmount),
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(goal.description, style: const TextStyle(fontSize: 14, color: AppColors.lightTextSecondary)),
                        const SizedBox(height: 20),
                        LinearPercentIndicator(
                          lineHeight: 12.0,
                          percent: goal.progressPercentage,
                          backgroundColor: AppColors.lightCardBorder,
                          progressColor: AppColors.primary,
                          barRadius: const Radius.circular(6),
                          padding: EdgeInsets.zero,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Saved: ${CurrencyFormatter.formatINR(goal.currentSaved)} (${(goal.progressPercentage * 100).toStringAsFixed(1)}%)',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Remaining: ${CurrencyFormatter.formatINR(goal.remainingAmount)}',
                              style: const TextStyle(color: AppColors.lightTextSecondary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Calculation & Affordability Breakdown Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.analytics_outlined, color: AppColors.primary),
                            SizedBox(width: 8),
                            Text(
                              'Goal Mathematical Breakdown',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildDetailStat('Target Date', CurrencyFormatter.formatDate(goal.targetDate)),
                            _buildDetailStat('Time Left', '${calcResult.monthsRemaining} months'),
                            _buildDetailStat('Required / Mo', CurrencyFormatter.formatINR(calcResult.requiredMonthlySavings)),
                            _buildDetailStat('Planned / Mo', CurrencyFormatter.formatINR(goal.plannedMonthlyContribution)),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: calcResult.isAffordable ? AppColors.success.withAlpha(20) : AppColors.warning.withAlpha(25),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: calcResult.isAffordable ? AppColors.success.withAlpha(60) : AppColors.warning.withAlpha(80),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: calcResult.recommendations.map((rec) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Text(rec, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Contribution History Header & Deposit Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Contribution History',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showAddContributionDialog(context, ref, goal),
                      icon: const Icon(Icons.add),
                      label: const Text('+ Deposit Funds'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                if (goal.contributions.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text('No deposits recorded yet.'),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: goal.contributions.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final c = goal.contributions[index];
                      return Card(
                        margin: EdgeInsets.zero,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primary.withAlpha(30),
                            child: const Icon(Icons.arrow_upward, color: AppColors.primary, size: 20),
                          ),
                          title: Text(
                            CurrencyFormatter.formatINR(c.amount),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          subtitle: Text('${c.userName} • ${c.note ?? "Contribution"}'),
                          trailing: Text(
                            CurrencyFormatter.formatFullDate(c.date),
                            style: const TextStyle(fontSize: 12, color: AppColors.lightTextSecondary),
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
        error: (err, _) => Text('Error loading goal: $err'),
      ),
    );
  }

  Widget _buildDetailStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.lightTextSecondary)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }

  void _showAddContributionDialog(BuildContext context, WidgetRef ref, GoalModel goal) {
    final amountController = TextEditingController();
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add Deposit to ${goal.title}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount (₹)',
                prefixText: '₹ ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(
                labelText: 'Note / Source (e.g. Salary, Bonus)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final amt = double.tryParse(amountController.text) ?? 0;
              if (amt > 0) {
                ref.read(goalProvider.notifier).addContribution(
                      goalId: goal.id,
                      amount: amt,
                      note: noteController.text.isNotEmpty ? noteController.text : null,
                    );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Added ₹${amt.toStringAsFixed(0)} deposit! +25 XP 🎉')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Add Deposit'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Goal?'),
        content: const Text('Are you sure you want to delete this dream goal? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ref.read(goalProvider.notifier).deleteGoal(goalId);
              Navigator.pop(ctx);
              context.go('/goals');
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
