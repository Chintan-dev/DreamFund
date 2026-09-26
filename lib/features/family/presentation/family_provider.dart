import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/family_model.dart';

final familyProvider = Provider<FamilyModel>((ref) {
  return FamilyModel(
    id: 'family_101',
    familyName: 'Patel Family Dream Vault',
    inviteCode: 'DREAM-7890',
    totalFamilySavings: 300000,
    members: [
      FamilyMember(
        userId: 'user_001',
        name: 'Chintan Patel',
        role: 'Family Admin',
        avatarUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Chintan',
        totalContributed: 250000,
      ),
      FamilyMember(
        userId: 'user_002',
        name: 'Pooja Patel',
        role: 'Co-Saver',
        avatarUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Pooja',
        totalContributed: 50000,
      ),
    ],
  );
});
