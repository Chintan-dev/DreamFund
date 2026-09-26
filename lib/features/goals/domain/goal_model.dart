import 'contribution_model.dart';

enum GoalCategory {
  technology,
  travel,
  vehicle,
  home,
  education,
  emergency,
  familyEvent,
  other,
}

class GoalModel {
  final String id;
  final String title;
  final String description;
  final double targetAmount;
  final double currentSaved;
  final double plannedMonthlyContribution;
  final DateTime targetDate;
  final DateTime createdAt;
  final GoalCategory category;
  final bool isSharedWithFamily;
  final String createdByUserId;
  final String iconName;
  final List<ContributionModel> contributions;

  GoalModel({
    required this.id,
    required this.title,
    required this.description,
    required this.targetAmount,
    required this.currentSaved,
    required this.plannedMonthlyContribution,
    required this.targetDate,
    required this.createdAt,
    required this.category,
    required this.isSharedWithFamily,
    required this.createdByUserId,
    this.iconName = 'savings',
    this.contributions = const [],
  });

  double get progressPercentage {
    if (targetAmount <= 0) return 0.0;
    return (currentSaved / targetAmount).clamp(0.0, 1.0);
  }

  double get remainingAmount {
    return (targetAmount - currentSaved).clamp(0.0, double.infinity);
  }

  bool get isCompleted => currentSaved >= targetAmount;

  GoalModel copyWith({
    String? title,
    String? description,
    double? targetAmount,
    double? currentSaved,
    double? plannedMonthlyContribution,
    DateTime? targetDate,
    GoalCategory? category,
    bool? isSharedWithFamily,
    String? iconName,
    List<ContributionModel>? contributions,
  }) {
    return GoalModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      targetAmount: targetAmount ?? this.targetAmount,
      currentSaved: currentSaved ?? this.currentSaved,
      plannedMonthlyContribution: plannedMonthlyContribution ?? this.plannedMonthlyContribution,
      targetDate: targetDate ?? this.targetDate,
      createdAt: createdAt,
      category: category ?? this.category,
      isSharedWithFamily: isSharedWithFamily ?? this.isSharedWithFamily,
      createdByUserId: createdByUserId,
      iconName: iconName ?? this.iconName,
      contributions: contributions ?? this.contributions,
    );
  }
}
