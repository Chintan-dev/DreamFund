class AchievementModel {
  final String id;
  final String title;
  final String description;
  final String icon;
  final int xpReward;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  AchievementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.xpReward,
    required this.isUnlocked,
    this.unlockedAt,
  });
}
