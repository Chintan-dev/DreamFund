import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/calculation_engine.dart';
import 'goal_provider.dart';
import '../domain/goal_model.dart';

class GoalListScreen extends ConsumerStatefulWidget {
  const GoalListScreen({super.key});

  @override
  ConsumerState<GoalListScreen> createState() => _GoalListScreenState();
}

class _GoalListScreenState extends ConsumerState<GoalListScreen> {
  String _selectedFilter = 'All'; // All, Personal, Family

  @override
  Widget build(BuildContext context) {
    final goalsAsync = ref.watch(goalProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Savings Dreams'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => context.go('/goals/create'),
            tooltip: 'Create New Goal',
          ),
        ],
      ),
      body: goalsAsync.when(
        data: (goals) {
          final filteredGoals = goals.where((g) {
            if (_selectedFilter == 'Personal') return !g.isSharedWithFamily;
            if (_selectedFilter == 'Family') return g.isSharedWithFamily;
            return true;
          }).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'All Planned Purchases & Dreams',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: ['All', 'Personal', 'Family'].map((filter) {
                        final isSelected = _selectedFilter == filter;
                        return Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: ChoiceChip(
                            label: Text(filter),
                            selected: isSelected,
                            selectedColor: AppColors.primary,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : AppColors.lightTextPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                            onSelected: (val) {
                              if (val) setState(() => _selectedFilter = filter);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (filteredGoals.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(40),
                    alignment: Alignment.center,
                    child: const Text('No goals match the selected filter.'),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredGoals.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final goal = filteredGoals[index];
                      return _buildGoalListItem(context, ref, goal);
                    },
                  ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Text('Error loading goals: $err'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/goals/create'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('New Dream Goal'),
      ),
    );
  }

  Widget _buildGoalListItem(BuildContext context, WidgetRef ref, GoalModel goal) {
    final calcResult = CalculationEngine.calculateGoalPlan(
      targetAmount: goal.targetAmount,
      currentSaved: goal.currentSaved,
      targetDate: goal.targetDate,
      plannedMonthlyContribution: goal.plannedMonthlyContribution,
    );

    return Card(
      child: InkWell(
        onTap: () => context.go('/goals/${goal.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(30),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.stars, color: AppColors.primary, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(goal.title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                          Text(
                            'Target: ${CurrencyFormatter.formatDate(goal.targetDate)} • ${calcResult.monthsRemaining} months remaining',
                            style: const TextStyle(fontSize: 12, color: AppColors.lightTextSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Text(
                    CurrencyFormatter.formatINR(goal.targetAmount),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              LinearPercentIndicator(
                lineHeight: 8.0,
                percent: goal.progressPercentage,
                backgroundColor: AppColors.lightCardBorder,
                progressColor: AppColors.primary,
                barRadius: const Radius.circular(4),
                padding: EdgeInsets.zero,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Saved: ${CurrencyFormatter.formatINR(goal.currentSaved)} (${(goal.progressPercentage * 100).toStringAsFixed(0)}%)',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'Planned: ${CurrencyFormatter.formatINR(goal.plannedMonthlyContribution)}/mo',
                    style: const TextStyle(fontSize: 13, color: AppColors.secondary, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
