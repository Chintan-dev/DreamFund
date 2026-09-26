class SavingsCalculationResult {
  final double targetAmount;
  final double currentSaved;
  final double remainingAmount;
  final int monthsRemaining;
  final int weeksRemaining;
  final double requiredMonthlySavings;
  final double requiredWeeklySavings;
  final double plannedMonthlyContribution;
  final double monthlyShortfallOrSurplus; // Negative = shortfall, Positive = surplus
  final bool isAffordable;
  final DateTime? estimatedCompletionDate;
  final List<String> recommendations;

  SavingsCalculationResult({
    required this.targetAmount,
    required this.currentSaved,
    required this.remainingAmount,
    required this.monthsRemaining,
    required this.weeksRemaining,
    required this.requiredMonthlySavings,
    required this.requiredWeeklySavings,
    required this.plannedMonthlyContribution,
    required this.monthlyShortfallOrSurplus,
    required this.isAffordable,
    this.estimatedCompletionDate,
    required this.recommendations,
  });
}

class CalculationEngine {
  /// Calculates monthly savings requirements, affordability, and recommendations
  static SavingsCalculationResult calculateGoalPlan({
    required double targetAmount,
    required double currentSaved,
    required DateTime targetDate,
    required double plannedMonthlyContribution,
    DateTime? fromDate,
  }) {
    final now = fromDate ?? DateTime.now();
    final remaining = (targetAmount - currentSaved).clamp(0.0, double.infinity);

    // Calculate months remaining (at least 1 month)
    int months = ((targetDate.year - now.year) * 12) + (targetDate.month - now.month);
    if (months <= 0) months = 1;

    // Calculate weeks remaining (at least 1 week)
    final daysRemaining = targetDate.difference(now).inDays;
    int weeks = (daysRemaining / 7).ceil();
    if (weeks <= 0) weeks = 1;

    final requiredMonthly = remaining / months;
    final requiredWeekly = remaining / weeks;

    final shortfallOrSurplus = plannedMonthlyContribution - requiredMonthly;
    final isAffordable = shortfallOrSurplus >= 0;

    // Calculate estimated completion date based on planned contribution
    DateTime? estimatedCompletion;
    if (plannedMonthlyContribution > 0) {
      final monthsNeeded = (remaining / plannedMonthlyContribution).ceil();
      estimatedCompletion = DateTime(now.year, now.month + monthsNeeded, now.day);
    }

    // Build smart recommendations
    final recommendations = <String>[];
    if (remaining == 0) {
      recommendations.add("🎉 Congratulations! Goal target reached!");
    } else if (isAffordable) {
      recommendations.add(
        "✅ You are on track! Saving ₹${plannedMonthlyContribution.toStringAsFixed(0)}/mo covers your target of ₹${requiredMonthly.toStringAsFixed(0)}/mo.",
      );
    } else {
      final deficit = shortfallOrSurplus.abs();
      recommendations.add(
        "⚠️ You are currently ₹${deficit.toStringAsFixed(0)}/month short of the required ₹${requiredMonthly.toStringAsFixed(0)}/month target.",
      );

      if (estimatedCompletion != null) {
        final delayedMonths = ((estimatedCompletion.year - targetDate.year) * 12) +
            (estimatedCompletion.month - targetDate.month);
        recommendations.add(
          "📅 Option 1: Extend your target date by $delayedMonths month(s) to reach it with current savings.",
        );
      }

      final extraPerWeek = (deficit / 4.33).ceil();
      recommendations.add(
        "💡 Option 2: Increase savings by ₹${extraPerWeek.toStringAsFixed(0)}/week to stay on schedule.",
      );

      final lowerTarget = currentSaved + (plannedMonthlyContribution * months);
      recommendations.add(
        "🎯 Option 3: Adjust target budget to ₹${lowerTarget.toStringAsFixed(0)} by your target date.",
      );
    }

    return SavingsCalculationResult(
      targetAmount: targetAmount,
      currentSaved: currentSaved,
      remainingAmount: remaining,
      monthsRemaining: months,
      weeksRemaining: weeks,
      requiredMonthlySavings: requiredMonthly,
      requiredWeeklySavings: requiredWeekly,
      plannedMonthlyContribution: plannedMonthlyContribution,
      monthlyShortfallOrSurplus: shortfallOrSurplus,
      isAffordable: isAffordable,
      estimatedCompletionDate: estimatedCompletion,
      recommendations: recommendations,
    );
  }
}
