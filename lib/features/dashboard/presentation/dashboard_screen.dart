import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/calculation_engine.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../goals/presentation/goal_provider.dart';
import '../../goals/domain/goal_model.dart';
import '../../budget/presentation/budget_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(authProvider);
    final goalsAsync = ref.watch(goalProvider);
    final budgetAsync = ref.watch(budgetProvider);
    final user = userAsync.value;

    final isWide = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primary.withAlpha(40),
              child: Text(
                user != null && user.name.isNotEmpty ? user.name[0] : 'U',
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good day, ${user?.name.split(' ').first ?? 'Dreamer'} 👋',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Family Dream Vault • ${user?.currentStreakDays ?? 1} Day Streak 🔥',
                  style: const TextStyle(fontSize: 12, color: AppColors.lightTextSecondary),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: AppColors.accentGold.withAlpha(30),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.accentGold.withAlpha(80)),
            ),
            child: Row(
              children: [
                const Icon(Icons.bolt, color: AppColors.accentGold, size: 18),
                const SizedBox(width: 4),
                Text(
                  'Level ${user?.level ?? 1} (${user?.xp ?? 0} XP)',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.lightTextPrimary),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Summary Metrics
            goalsAsync.when(
              data: (goals) {
                double totalSaved = 0;
                double totalTarget = 0;
                double totalPlannedMonthly = 0;

                for (var g in goals) {
                  totalSaved += g.currentSaved;
                  totalTarget += g.targetAmount;
                  totalPlannedMonthly += g.plannedMonthlyContribution;
                }

                final overallProgress = totalTarget > 0 ? (totalSaved / totalTarget).clamp(0.0, 1.0) : 0.0;

                return Column(
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return Flex(
                          direction: isWide ? Axis.horizontal : Axis.vertical,
                          children: [
                            Expanded(
                              flex: isWide ? 1 : 0,
                              child: _buildMetricCard(
                                title: 'Total Savings Vault',
                                value: CurrencyFormatter.formatINR(totalSaved),
                                subtitle: 'Target: ${CurrencyFormatter.formatINR(totalTarget)}',
                                icon: Icons.account_balance,
                                color: AppColors.primary,
                                child: Column(
                                  children: [
                                    const SizedBox(height: 12),
                                    LinearPercentIndicator(
                                      lineHeight: 8.0,
                                      percent: overallProgress,
                                      backgroundColor: AppColors.lightCardBorder,
                                      progressColor: AppColors.primary,
                                      barRadius: const Radius.circular(4),
                                      padding: EdgeInsets.zero,
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${(overallProgress * 100).toStringAsFixed(1)}% Funded',
                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                                        ),
                                        Text(
                                          '${goals.length} Active Dreams',
                                          style: const TextStyle(fontSize: 12, color: AppColors.lightTextSecondary),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (isWide) const SizedBox(width: 16) else const SizedBox(height: 16),
                            Expanded(
                              flex: isWide ? 1 : 0,
                              child: _buildMetricCard(
                                title: 'Monthly Goal Plan',
                                value: CurrencyFormatter.formatINR(totalPlannedMonthly),
                                subtitle: 'Auto-budgeted across all active goals',
                                icon: Icons.savings_outlined,
                                color: AppColors.secondary,
                              ),
                            ),
                            if (isWide) const SizedBox(width: 16) else const SizedBox(height: 16),
                            Expanded(
                              flex: isWide ? 1 : 0,
                              child: budgetAsync.when(
                                data: (budget) => _buildMetricCard(
                                  title: 'Monthly Cash Surplus',
                                  value: CurrencyFormatter.formatINR(budget.unallocatedSurplus),
                                  subtitle: 'Available income after expenses & goals',
                                  icon: Icons.trending_up,
                                  color: budget.unallocatedSurplus >= 0 ? AppColors.success : AppColors.error,
                                ),
                                loading: () => const Center(child: CircularProgressIndicator()),
                                error: (_, __) => const SizedBox.shrink(),
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 28),

                    // Active Dream Goals Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Active Dream Goals',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Track target dates and monthly contribution status',
                              style: TextStyle(fontSize: 13, color: AppColors.lightTextSecondary),
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: () => context.go('/goals/create'),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('+ New Dream Goal'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Goal Cards List
                    if (goals.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(32),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardTheme.color,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.lightCardBorder),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.stars, size: 48, color: AppColors.primary),
                            const SizedBox(height: 12),
                            const Text(
                              'No savings goals created yet!',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Set up a target price and date for what you want to achieve.',
                              style: TextStyle(fontSize: 13, color: AppColors.lightTextSecondary),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => context.go('/goals/create'),
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                              child: const Text('Create First Dream Goal'),
                            ),
                          ],
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: goals.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final goal = goals[index];
                          return _buildGoalCard(context, ref, goal);
                        },
                      ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Text('Error loading goals: $err'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    Widget? child,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.lightTextSecondary),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withAlpha(30),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: -0.5),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: AppColors.lightTextSecondary),
            ),
            if (child != null) child,
          ],
        ),
      ),
    );
  }

  Widget _buildGoalCard(BuildContext context, WidgetRef ref, GoalModel goal) {
    final calcResult = CalculationEngine.calculateGoalPlan(
      targetAmount: goal.targetAmount,
      currentSaved: goal.currentSaved,
      targetDate: goal.targetDate,
      plannedMonthlyContribution: goal.plannedMonthlyContribution,
    );

    return InkWell(
      onTap: () => context.go('/goals/${goal.id}'),
      borderRadius: BorderRadius.circular(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(_getCategoryIcon(goal.category), color: AppColors.primary, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              goal.title,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            if (goal.isSharedWithFamily) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.secondary.withAlpha(30),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.family_restroom, size: 12, color: AppColors.secondary),
                                    SizedBox(width: 4),
                                    Text('Family Shared', style: TextStyle(fontSize: 10, color: AppColors.secondary, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          goal.description,
                          style: const TextStyle(fontSize: 13, color: AppColors.lightTextSecondary),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    CurrencyFormatter.formatINR(goal.targetAmount),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              LinearPercentIndicator(
                lineHeight: 10.0,
                percent: goal.progressPercentage,
                backgroundColor: AppColors.lightCardBorder,
                progressColor: goal.isCompleted ? AppColors.success : AppColors.primary,
                barRadius: const Radius.circular(5),
                padding: EdgeInsets.zero,
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Saved: ${CurrencyFormatter.formatINR(goal.currentSaved)} (${(goal.progressPercentage * 100).toStringAsFixed(0)}%)',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'Target: ${CurrencyFormatter.formatDate(goal.targetDate)}',
                    style: const TextStyle(fontSize: 13, color: AppColors.lightTextSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: calcResult.isAffordable ? AppColors.success.withAlpha(20) : AppColors.warning.withAlpha(25),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: calcResult.isAffordable ? AppColors.success.withAlpha(60) : AppColors.warning.withAlpha(80),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      calcResult.isAffordable ? Icons.check_circle_outline : Icons.info_outline,
                      size: 18,
                      color: calcResult.isAffordable ? AppColors.success : AppColors.warning,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        calcResult.recommendations.first,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: calcResult.isAffordable ? AppColors.success : AppColors.warning,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _showAddContributionDialog(context, ref, goal),
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Deposit'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(GoalCategory category) {
    switch (category) {
      case GoalCategory.technology:
        return Icons.computer;
      case GoalCategory.travel:
        return Icons.flight_takeoff;
      case GoalCategory.vehicle:
        return Icons.directions_car;
      case GoalCategory.home:
        return Icons.home;
      case GoalCategory.education:
        return Icons.school;
      case GoalCategory.emergency:
        return Icons.shield;
      case GoalCategory.familyEvent:
        return Icons.celebration;
      case GoalCategory.other:
        return Icons.stars;
    }
  }

  void _showAddContributionDialog(BuildContext context, WidgetRef ref, GoalModel goal) {
    final amountController = TextEditingController();
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add Contribution to ${goal.title}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Contribution Amount (₹)',
                prefixText: '₹ ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(
                labelText: 'Note (Optional)',
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
                  SnackBar(content: Text('Added ₹${amt.toStringAsFixed(0)} deposit to ${goal.title}! +25 XP 🎉')),
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
}
