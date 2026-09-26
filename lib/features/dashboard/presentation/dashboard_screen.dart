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

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _activeTab = 0; // 0: Active Dreams, 1: Activity Log

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(authProvider);
    final goalsAsync = ref.watch(goalProvider);
    final budgetAsync = ref.watch(budgetProvider);
    final user = userAsync.value;

    final isWide = MediaQuery.of(context).size.width >= 1000;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dashboard Page Title Header Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Overview Dashboard',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 26),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Welcome back, ${user?.name ?? "Dreamer"} • Track family savings & financial goals',
                      style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.darkSurface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.darkCardBorder),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.textMuted),
                          SizedBox(width: 8),
                          Text(
                            'Year 2026',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Top 4 Dashtrans Shadcn Stat Cards Grid
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
                        return GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: isWide ? 4 : (MediaQuery.of(context).size.width >= 600 ? 2 : 1),
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 1.6,
                          children: [
                            // Stat 1: Total Savings Vault
                            _buildShadcnStatCard(
                              title: 'TOTAL SAVINGS VAULT',
                              value: CurrencyFormatter.formatINR(totalSaved),
                              trend: '+14.5%',
                              trendPositive: true,
                              subtitle: '${(overallProgress * 100).toStringAsFixed(1)}% of total target',
                              icon: Icons.account_balance_rounded,
                              gradient: AppColors.primaryGradient,
                              progress: overallProgress,
                            ),

                            // Stat 2: Monthly Goal Plan
                            _buildShadcnStatCard(
                              title: 'MONTHLY GOAL PLAN',
                              value: CurrencyFormatter.formatINR(totalPlannedMonthly),
                              trend: 'Auto-Budgeted',
                              trendPositive: true,
                              subtitle: '${goals.length} Active savings targets',
                              icon: Icons.savings_rounded,
                              gradient: AppColors.indigoGradient,
                            ),

                            // Stat 3: Cash Surplus
                            budgetAsync.when(
                              data: (budget) => _buildShadcnStatCard(
                                title: 'UNALLOCATED SURPLUS',
                                value: CurrencyFormatter.formatINR(budget.unallocatedSurplus),
                                trend: budget.unallocatedSurplus >= 0 ? 'Healthy' : 'Deficit',
                                trendPositive: budget.unallocatedSurplus >= 0,
                                subtitle: 'Available income buffer',
                                icon: Icons.trending_up_rounded,
                                gradient: const LinearGradient(colors: [Color(0xFF06B6D4), Color(0xFF3B82F6)]),
                              ),
                              loading: () => const SizedBox.shrink(),
                              error: (err, stack) => const SizedBox.shrink(),
                            ),

                            // Stat 4: Gamification XP & Level
                            _buildShadcnStatCard(
                              title: 'SAVINGS LEVEL & XP',
                              value: 'Level ${user?.level ?? 1}',
                              trend: '${user?.currentStreakDays ?? 1}d Streak 🔥',
                              trendPositive: true,
                              subtitle: '${user?.xp ?? 0} Total XP Earned',
                              icon: Icons.emoji_events_rounded,
                              gradient: const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFF43F5E)]),
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 28),

                    // Tab Navigation Bar (Shadcn UI style)
                    Row(
                      children: [
                        _buildTabButton('Active Savings Dreams (${goals.length})', index: 0),
                        const SizedBox(width: 12),
                        _buildTabButton('Recent Activity & Log', index: 1),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Content View based on Tab
                    if (_activeTab == 0) ...[
                      if (goals.isEmpty)
                        _buildEmptyGoalsCard(context)
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: goals.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final goal = goals[index];
                            return _buildDashtransGoalCard(context, ref, goal);
                          },
                        ),
                    ] else ...[
                      _buildDashtransDataTable(context, ref),
                    ],
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Text('Error loading goals: $err'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShadcnStatCard({
    required String title,
    required String value,
    required String trend,
    required bool trendPositive,
    required String subtitle,
    required IconData icon,
    required LinearGradient gradient,
    double? progress,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkCardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted, letterSpacing: 0.8),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white, size: 18),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    value,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: -0.5, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: (trendPositive ? AppColors.success : AppColors.error).withAlpha(30),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      trend,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: trendPositive ? AppColors.success : AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
            ],
          ),
          if (progress != null) ...[
            LinearPercentIndicator(
              lineHeight: 6.0,
              percent: progress,
              backgroundColor: AppColors.darkBackground,
              progressColor: AppColors.primary,
              barRadius: const Radius.circular(3),
              padding: EdgeInsets.zero,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, {required int index}) {
    final isSelected = _activeTab == index;
    return InkWell(
      onTap: () => setState(() => _activeTab = index),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withAlpha(30) : AppColors.darkSurface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.darkCardBorder),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildDashtransGoalCard(BuildContext context, WidgetRef ref, GoalModel goal) {
    final calcResult = CalculationEngine.calculateGoalPlan(
      targetAmount: goal.targetAmount,
      currentSaved: goal.currentSaved,
      targetDate: goal.targetDate,
      plannedMonthlyContribution: goal.plannedMonthlyContribution,
    );

    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkCardBorder),
      ),
      child: InkWell(
        onTap: () => context.go('/goals/${goal.id}'),
        borderRadius: BorderRadius.circular(16),
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
                      border: Border.all(color: AppColors.primary.withAlpha(40)),
                    ),
                    child: Icon(_getCategoryIcon(goal.category), color: AppColors.primary, size: 22),
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
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            if (goal.isSharedWithFamily) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.secondary.withAlpha(30),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: AppColors.secondary.withAlpha(60)),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.groups_rounded, size: 12, color: AppColors.secondary),
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
                          style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    CurrencyFormatter.formatINR(goal.targetAmount),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              LinearPercentIndicator(
                lineHeight: 8.0,
                percent: goal.progressPercentage,
                backgroundColor: AppColors.darkBackground,
                progressColor: goal.isCompleted ? AppColors.success : AppColors.primary,
                barRadius: const Radius.circular(4),
                padding: EdgeInsets.zero,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Saved: ${CurrencyFormatter.formatINR(goal.currentSaved)} (${(goal.progressPercentage * 100).toStringAsFixed(0)}%)',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                  Text(
                    'Target: ${CurrencyFormatter.formatDate(goal.targetDate)} • ${calcResult.monthsRemaining} mos left',
                    style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: calcResult.isAffordable ? AppColors.success.withAlpha(15) : AppColors.warning.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: calcResult.isAffordable ? AppColors.success.withAlpha(50) : AppColors.warning.withAlpha(60),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      calcResult.isAffordable ? Icons.check_circle_outline_rounded : Icons.info_outline_rounded,
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
                    ElevatedButton.icon(
                      onPressed: () => _showAddContributionDialog(context, ref, goal),
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('+ Deposit'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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

  Widget _buildDashtransDataTable(BuildContext context, WidgetRef ref) {
    final budgetAsync = ref.watch(budgetProvider);

    return budgetAsync.when(
      data: (budget) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.darkCardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Financial Activity Log', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text('Showing recent transactions & goal deposits', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.darkCardBorder),
              DataTable(
                columns: const [
                  DataColumn(label: Text('DATE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted))),
                  DataColumn(label: Text('DESCRIPTION', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted))),
                  DataColumn(label: Text('CATEGORY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted))),
                  DataColumn(label: Text('AMOUNT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted))),
                  DataColumn(label: Text('STATUS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted))),
                ],
                rows: budget.recentTransactions.map((tx) {
                  return DataRow(
                    cells: [
                      DataCell(Text(CurrencyFormatter.formatFullDate(tx.date), style: const TextStyle(fontSize: 13))),
                      DataCell(Text(tx.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.darkBackground,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.darkCardBorder),
                          ),
                          child: Text(tx.category, style: const TextStyle(fontSize: 11)),
                        ),
                      ),
                      DataCell(
                        Text(
                          CurrencyFormatter.formatINR(tx.amount),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: tx.type.name == 'income' ? AppColors.success : AppColors.error,
                          ),
                        ),
                      ),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.success.withAlpha(25),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('Cleared', style: TextStyle(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => const SizedBox.shrink(),
    );
  }

  Widget _buildEmptyGoalsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkCardBorder),
      ),
      child: Column(
        children: [
          const Icon(Icons.stars, size: 48, color: AppColors.primary),
          const SizedBox(height: 16),
          const Text('No active savings goals found!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Create your first dream purchase goal to enable smart projections.', style: TextStyle(color: AppColors.textMuted)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => context.go('/goals/create'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Create First Dream Goal'),
          ),
        ],
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
        backgroundColor: AppColors.darkSurface,
        title: Text('Add Deposit to ${goal.title}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
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
