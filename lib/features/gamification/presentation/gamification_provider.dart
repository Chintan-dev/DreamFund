import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/achievement_model.dart';

final achievementsProvider = Provider<List<AchievementModel>>((ref) {
  return [
    AchievementModel(
      id: 'ach_001',
      title: 'First Dreamer',
      description: 'Created your first financial goal in DreamFund',
      icon: '🎯',
      xpReward: 50,
      isUnlocked: true,
      unlockedAt: DateTime(2026, 1, 1),
    ),
    AchievementModel(
      id: 'ach_002',
      title: 'Savings Kickstart',
      description: 'Made your first contribution towards a dream goal',
      icon: '💰',
      xpReward: 100,
      isUnlocked: true,
      unlockedAt: DateTime(2026, 1, 15),
    ),
    AchievementModel(
      id: 'ach_003',
      title: 'Family Synergy',
      description: 'Created or joined a shared Family Dream Vault',
      icon: '👨‍👩‍👧‍👦',
      xpReward: 150,
      isUnlocked: true,
      unlockedAt: DateTime(2026, 1, 20),
    ),
    AchievementModel(
      id: 'ach_004',
      title: 'Halfway Hero',
      description: 'Reached 50% completion on any goal',
      icon: '🚀',
      xpReward: 200,
      isUnlocked: false,
    ),
    AchievementModel(
      id: 'ach_005',
      title: 'Dream Achieved',
      description: 'Fully funded a goal target 100%',
      icon: '👑',
      xpReward: 500,
      isUnlocked: false,
    ),
    AchievementModel(
      id: 'ach_006',
      title: '7-Day Savings Streak',
      description: 'Logged into DreamFund 7 days in a row',
      icon: '🔥',
      xpReward: 100,
      isUnlocked: true,
      unlockedAt: DateTime(2026, 9, 25),
    ),
  ];
});
