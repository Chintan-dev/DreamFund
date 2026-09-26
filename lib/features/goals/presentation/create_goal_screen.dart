import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/calculation_engine.dart';
import '../domain/goal_model.dart';
import 'goal_provider.dart';

class CreateGoalScreen extends ConsumerStatefulWidget {
  const CreateGoalScreen({super.key});

  @override
  ConsumerState<CreateGoalScreen> createState() => _CreateGoalScreenState();
}

class _CreateGoalScreenState extends ConsumerState<CreateGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetAmountController = TextEditingController();
  final _initialSavedController = TextEditingController(text: '0');
  final _monthlyPlannedController = TextEditingController();

  DateTime _targetDate = DateTime.now().add(const Duration(days: 365));
  GoalCategory _selectedCategory = GoalCategory.technology;
  bool _isSharedWithFamily = false;

  void _onFormChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final targetAmt = double.tryParse(_targetAmountController.text) ?? 0;
    final initialSaved = double.tryParse(_initialSavedController.text) ?? 0;
    final monthlyPlanned = double.tryParse(_monthlyPlannedController.text) ?? 0;

    final calcResult = targetAmt > 0
        ? CalculationEngine.calculateGoalPlan(
            targetAmount: targetAmt,
            currentSaved: initialSaved,
            targetDate: _targetDate,
            plannedMonthlyContribution: monthlyPlanned,
          )
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Savings Dream'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/goals'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          onChanged: _onFormChanged,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Plan What You Want To Achieve',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'Set your target price and date. DreamFund calculates monthly requirements automatically.',
                style: TextStyle(fontSize: 13, color: AppColors.lightTextSecondary),
              ),
              const SizedBox(height: 24),

              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Goal Title (e.g. Gaming PC, Europe Trip)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.flag_outlined),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Please enter a goal title' : null,
              ),
              const SizedBox(height: 16),

              // Category & Shared Toggle Row
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<GoalCategory>(
                      initialValue: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category_outlined),
                      ),
                      items: GoalCategory.values.map((cat) {
                        return DropdownMenuItem(
                          value: cat,
                          child: Text(cat.name[0].toUpperCase() + cat.name.substring(1)),
                        );
                      }).toList(),
                      onChanged: (cat) {
                        if (cat != null) setState(() => _selectedCategory = cat);
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SwitchListTile(
                      title: const Text('Family Shared', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      subtitle: const Text('Allow family to contribute', style: TextStyle(fontSize: 11)),
                      value: _isSharedWithFamily,
                      activeThumbColor: AppColors.primary,
                      onChanged: (val) => setState(() => _isSharedWithFamily = val),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Target Amount & Initial Savings
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _targetAmountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Target Price (₹)',
                        prefixText: '₹ ',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                      ),
                      validator: (val) {
                        final amt = double.tryParse(val ?? '');
                        return amt == null || amt <= 0 ? 'Enter valid target amount' : null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _initialSavedController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Already Saved (₹)',
                        prefixText: '₹ ',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.savings_outlined),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Planned Monthly Savings & Target Date
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _monthlyPlannedController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Planned Monthly Savings (₹)',
                        prefixText: '₹ ',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_month_outlined),
                      ),
                      validator: (val) {
                        final amt = double.tryParse(val ?? '');
                        return amt == null || amt < 0 ? 'Enter valid monthly savings' : null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _targetDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 3650)),
                        );
                        if (picked != null) {
                          setState(() => _targetDate = picked);
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Target Date',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.event),
                        ),
                        child: Text(
                          DateFormat('MMMM yyyy').format(_targetDate),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Description / Notes',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.notes),
                ),
              ),

              const SizedBox(height: 24),

              // Real-Time Math & Affordability Calculation Engine Box
              if (calcResult != null) ...[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primary.withAlpha(60)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.auto_awesome, color: AppColors.primary, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'DreamFund Smart Savings Engine',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildCalcSummaryTile('Months Remaining', '${calcResult.monthsRemaining} months'),
                          _buildCalcSummaryTile('Required Monthly', CurrencyFormatter.formatINR(calcResult.requiredMonthlySavings)),
                          _buildCalcSummaryTile('Required Weekly', CurrencyFormatter.formatINR(calcResult.requiredWeeklySavings)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: calcResult.recommendations.map((rec) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text(rec, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      ref.read(goalProvider.notifier).createGoal(
                            title: _titleController.text.trim(),
                            description: _descriptionController.text.trim(),
                            targetAmount: targetAmt,
                            initialSaved: initialSaved,
                            plannedMonthlyContribution: monthlyPlanned,
                            targetDate: _targetDate,
                            category: _selectedCategory,
                            isSharedWithFamily: _isSharedWithFamily,
                          );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Created Dream Goal! +50 XP Earned 🎉')),
                      );
                      context.go('/goals');
                    }
                  },
                  icon: const Icon(Icons.rocket_launch),
                  label: const Text('Create Dream Goal (+50 XP)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalcSummaryTile(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.lightTextSecondary)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
