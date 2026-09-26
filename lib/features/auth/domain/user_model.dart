class UserModel {
  final String id;
  final String name;
  final String email;
  final String avatarUrl;
  final String? familyId;
  final int xp;
  final int level;
  final int currentStreakDays;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.avatarUrl,
    this.familyId,
    this.xp = 0,
    this.level = 1,
    this.currentStreakDays = 1,
  });

  UserModel copyWith({
    String? name,
    String? email,
    String? avatarUrl,
    String? familyId,
    int? xp,
    int? level,
    int? currentStreakDays,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      familyId: familyId ?? this.familyId,
      xp: xp ?? this.xp,
      level: level ?? this.level,
      currentStreakDays: currentStreakDays ?? this.currentStreakDays,
    );
  }
}
