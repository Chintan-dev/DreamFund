class FamilyMember {
  final String userId;
  final String name;
  final String role; // e.g. Owner, Partner, Child
  final String avatarUrl;
  final double totalContributed;

  FamilyMember({
    required this.userId,
    required this.name,
    required this.role,
    required this.avatarUrl,
    required this.totalContributed,
  });
}

class FamilyModel {
  final String id;
  final String familyName;
  final String inviteCode;
  final List<FamilyMember> members;
  final double totalFamilySavings;

  FamilyModel({
    required this.id,
    required this.familyName,
    required this.inviteCode,
    required this.members,
    required this.totalFamilySavings,
  });
}
