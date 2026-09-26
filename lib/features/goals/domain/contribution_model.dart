class ContributionModel {
  final String id;
  final String goalId;
  final String userId;
  final String userName;
  final double amount;
  final DateTime date;
  final String? note;

  ContributionModel({
    required this.id,
    required this.goalId,
    required this.userId,
    required this.userName,
    required this.amount,
    required this.date,
    this.note,
  });
}
